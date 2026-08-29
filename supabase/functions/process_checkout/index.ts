import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// CORS headers for browser requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Initialize Supabase Client with Service Role (Bypasses RLS to read products and insert orders securely)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. Authenticate the User
    const authHeader = req.headers.get('Authorization')!
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    // 3. Parse the Request Payload
    const { 
      shipping_address_id, 
      delivery_method_id, 
      payment_method 
    } = await req.json()

    if (!shipping_address_id || !delivery_method_id || !payment_method) {
       throw new Error('Missing required fields')
    }

    // 4. Fetch User's Cart Items
    const { data: cartItems, error: cartError } = await supabaseClient
      .from('cart_items')
      .select('*')
      .eq('user_id', user.id)

    if (cartError || !cartItems || cartItems.length === 0) {
      throw new Error('Cart is empty')
    }

    // 5. Fetch Delivery Method to get the delivery charge
    const { data: deliveryMethod, error: deliveryError } = await supabaseClient
      .from('delivery_methods')
      .select('*')
      .eq('id', delivery_method_id)
      .single()

    if (deliveryError || !deliveryMethod) {
      throw new Error('Invalid delivery method')
    }

    const deliveryCharge = parseFloat(deliveryMethod.charge.toString())

    // 6. Calculate Subtotal securely
    let subtotal = 0
    const orderItemsToInsert = []

    for (const item of cartItems) {
      let product;
      
      // Handle dynamic AI custom products (not stored in the products table)
      if (item.product_id && item.product_id.startsWith('ai_custom_')) {
        product = {
          id: item.product_id,
          name: 'Custom Typography Tee',
          price: 2499.00,
          tag: 'Custom'
        };
      } else {
        // Fetch the real product price from the database for normal products
        const { data: dbProduct, error: productError } = await supabaseClient
          .from('products')
          .select('*')
          .eq('id', item.product_id)
          .single()

        if (productError || !dbProduct) {
          throw new Error(`Product not found: ${item.product_id}`)
        }
        product = dbProduct;
      }

      const unitPrice = parseFloat(product.price.toString())
      const quantity = parseInt(item.quantity.toString())
      const itemTotal = unitPrice * quantity
      
      subtotal += itemTotal

      orderItemsToInsert.push({
        product_id: product.id,
        product_name: product.name,
        size: item.size,
        custom_text: item.custom_text,
        quantity: quantity,
        unit_price: unitPrice,
        total_price: itemTotal,
        front_design_preview: item.front_design_preview,
        back_design_preview: item.back_design_preview,
        front_print_url: item.front_print_url,
        back_print_url: item.back_print_url,
        front_mockup_url: item.front_mockup_url,
        back_mockup_url: item.back_mockup_url,
        tag: product.tag
      })
    }

    // 7. Calculate final totals (e.g., 18% GST)
    const discount = 0 // Apply any promo codes here if needed
    const gstRate = 0.18
    const gst = parseFloat((subtotal * gstRate).toFixed(2))
    const total = parseFloat((subtotal - discount + deliveryCharge + gst).toFixed(2))

    // 8. Generate Order ID (ORD_XXXXXX)
    const orderId = 'ORD_' + Math.random().toString(36).substring(2, 8).toUpperCase()
    
    const now = new Date()
    // Calculate estimated delivery
    const estimatedDelivery = new Date()
    const daysToAdd = deliveryMethod.type === 'express' ? 3 : (deliveryMethod.type === 'same_day' ? 0 : 6)
    estimatedDelivery.setDate(estimatedDelivery.getDate() + daysToAdd)

    let razorpayOrderId = null
    let finalPaymentStatus = 'pending'

    if (payment_method !== 'Cash on Delivery') {
      // Call Razorpay API to generate order
      const rzpKey = Deno.env.get('RAZORPAY_KEY_ID')
      const rzpSecret = Deno.env.get('RAZORPAY_KEY_SECRET')

      if (!rzpKey || !rzpSecret) {
        throw new Error('Razorpay keys are not configured')
      }

      // Amount in paise
      const amountInPaise = Math.round(total * 100)

      const basicAuth = btoa(`${rzpKey}:${rzpSecret}`)
      const rzpResponse = await fetch('https://api.razorpay.com/v1/orders', {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${basicAuth}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          amount: amountInPaise,
          currency: 'INR',
          receipt: orderId
        })
      })

      const rzpData = await rzpResponse.json()
      if (!rzpResponse.ok) {
        throw new Error(`Razorpay Error: ${rzpData.error?.description || 'Failed to create order'}`)
      }
      
      razorpayOrderId = rzpData.id
    }

    // 9. Create the Order in Supabase
    const { error: insertOrderError } = await supabaseClient
      .from('orders')
      .insert({
        id: orderId,
        user_id: user.id,
        shipping_address_id: shipping_address_id,
        delivery_method_id: delivery_method_id,
        payment_method: payment_method,
        payment_status: finalPaymentStatus,
        status: 'processing',
        subtotal: subtotal,
        discount: discount,
        delivery_charge: deliveryCharge,
        gst: gst,
        total: total,
        razorpay_order_id: razorpayOrderId,
        estimated_delivery: estimatedDelivery.toISOString()
      })

    if (insertOrderError) {
      throw insertOrderError
    }

    // 10. Insert Order Items
    const itemsWithOrderId = orderItemsToInsert.map(item => ({ ...item, order_id: orderId }))
    const { error: insertItemsError } = await supabaseClient
      .from('order_items')
      .insert(itemsWithOrderId)

    if (insertItemsError) {
      throw insertItemsError
    }

    // 11. Clear the User's Cart if COD
    if (payment_method === 'Cash on Delivery') {
      await supabaseClient
        .from('cart_items')
        .delete()
        .eq('user_id', user.id)
    }

    // 12. Return Success
    return new Response(
      JSON.stringify({ 
        success: true, 
        order_id: orderId,
        razorpay_order_id: razorpayOrderId,
        total: total,
        message: 'Order created successfully'
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
