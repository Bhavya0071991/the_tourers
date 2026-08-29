import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { hmac } from "https://deno.land/x/crypto@v0.10.0/hmac.ts"

// CORS headers for browser requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Authenticate the User
    const authHeader = req.headers.get('Authorization')!
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    const { 
      order_id, 
      razorpay_payment_id, 
      razorpay_order_id, 
      razorpay_signature 
    } = await req.json()

    if (!order_id || !razorpay_payment_id || !razorpay_order_id || !razorpay_signature) {
      throw new Error('Missing required fields')
    }

    const rzpSecret = Deno.env.get('RAZORPAY_KEY_SECRET')
    if (!rzpSecret) {
      throw new Error('Razorpay secret not configured')
    }

    // Verify Signature
    const body = razorpay_order_id + "|" + razorpay_payment_id
    const expectedSignatureBytes = hmac(
      "sha256", 
      new TextEncoder().encode(rzpSecret), 
      new TextEncoder().encode(body)
    )
    
    // Convert Uint8Array to hex string
    const expectedSignature = Array.from(new Uint8Array(expectedSignatureBytes as any))
      .map((b: any) => b.toString(16).padStart(2, '0'))
      .join('')

    if (expectedSignature !== razorpay_signature) {
      throw new Error('Invalid signature')
    }

    // Update order status to paid and save payment ID
    const { error: updateError } = await supabaseClient
      .from('orders')
      .update({ 
        payment_status: 'paid',
        razorpay_payment_id: razorpay_payment_id 
      })
      .eq('id', order_id)
      .eq('user_id', user.id) // Ensure the order belongs to the user

    if (updateError) {
      throw updateError
    }

    // Clear the cart since payment succeeded
    await supabaseClient
      .from('cart_items')
      .delete()
      .eq('user_id', user.id)

    // Trigger Qikink Sync
    // We must await this so the edge function doesn't terminate before the request is sent!
    const invokeRes = await supabaseClient.functions.invoke('sync-qikink-order', {
      body: { order_id: order_id }
    });
    
    console.log("Qikink invoke response:", invokeRes);

    if (invokeRes.error) {
       console.error("Qikink Invoke Error details:", invokeRes.error);
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Payment verified successfully' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
