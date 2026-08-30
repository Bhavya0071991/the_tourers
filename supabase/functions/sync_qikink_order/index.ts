import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // Using service role to bypass RLS for background jobs
    )

    const { order_id } = await req.json()
    if (!order_id) {
      throw new Error('Missing order_id')
    }

    const qikinkClientId = Deno.env.get('QIKINK_CLIENT_ID')
    const qikinkClientSecret = Deno.env.get('QIKINK_CLIENT_SECRET')

    if (!qikinkClientId || !qikinkClientSecret) {
      throw new Error('Qikink Client ID or Secret is missing in Edge Function secrets')
    }

    console.log(`DEBUG: Client ID length: ${qikinkClientId.length}, Value: '${qikinkClientId}'`);
    console.log(`DEBUG: Secret length: ${qikinkClientSecret.length}, Starts with: '${qikinkClientSecret.substring(0, 3)}', Ends with: '${qikinkClientSecret.substring(qikinkClientSecret.length - 3)}'`);

    // 1. Fetch Order Details from Supabase
    console.log(`DEBUG: Fetching order ID ${order_id} from Supabase...`);
    const { data: orderData, error: orderError } = await supabaseClient
      .from('orders')
      .select(`
        *,
        user_addresses(*),
        order_items(*)
      `)
      .eq('id', order_id)
      .single()

    if (orderError || !orderData) {
      throw new Error(`Order not found: ${JSON.stringify(orderError)}`)
    }

    console.log(`DEBUG: Order fetched successfully. Sync status: ${orderData.printful_sync_status}`);

    // Prevent duplicate syncing
    if (orderData.printful_sync_status === 'success') {
      console.log(`DEBUG: Order already synced, exiting.`);
      return new Response(JSON.stringify({ message: 'Order already synced' }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 })
    }

    const address = orderData.user_addresses;
    if (!address) {
       throw new Error('No shipping address found for order');
    }

    // 2. Generate Access Token from Qikink
    console.log(`DEBUG: Generating Access Token from Qikink...`);
    const tokenResponse = await fetch('https://sandbox.qikink.com/api/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        'ClientId': qikinkClientId,
        'client_secret': qikinkClientSecret
      })
    });

    console.log(`DEBUG: Token response status: ${tokenResponse.status}`);
    const tokenData = await tokenResponse.json();
    if (!tokenResponse.ok || !tokenData.Accesstoken) {
       throw new Error(`Failed to get Qikink Access Token: ${JSON.stringify(tokenData)}`);
    }
    const accessToken = tokenData.Accesstoken;

    console.log(`DEBUG: Generated Accesstoken length: ${accessToken.length}`);

    console.log(`DEBUG: Uploading designs to Supabase Storage...`);
    const qikinkItems = [];
    
    for (const item of orderData.order_items) {
      const userSize = (item.size || 'M').toUpperCase();
      let finalFrontDesignUrl = "";
      let finalFrontMockupUrl = "";
      let finalBackDesignUrl = "";
      let finalBackMockupUrl = "";

      // Fetch product details explicitly if it's a regular product (not ai_custom)
      let productDetails = null;
      if (item.product_id && !item.product_id.startsWith('ai_custom_')) {
        const { data: pData } = await supabaseClient
          .from('products')
          .select('*')
          .eq('id', item.product_id)
          .single();
        productDetails = pData;
      }

      // 1. Check if it's a pre-built product from Admin Panel (Admin uploads transparent png to color_design_images)
      if (productDetails && productDetails.color_design_images && productDetails.color_design_images.length > 0) {
        console.log(`DEBUG: Found pre-built transparent image for product ${productDetails.id}`);
        finalFrontDesignUrl = productDetails.color_design_images[0];
        finalFrontMockupUrl = productDetails.mockup || productDetails.image || finalFrontDesignUrl;
      } 
      // 2. Check if a transparent print url was passed in the order item
      else if (item.front_print_url) {
        console.log(`DEBUG: Found front_print_url in order item`);
        finalFrontDesignUrl = item.front_print_url;
        finalFrontMockupUrl = item.front_mockup_url || item.front_design_preview || item.front_print_url;
      }
      // 2. Otherwise, check if it's a custom AI Lab design (Base64)
      else if (item.front_design_preview) {
        if (item.front_design_preview.startsWith('http')) {
           finalFrontDesignUrl = item.front_design_preview;
           finalFrontMockupUrl = item.front_design_preview;
        } else {
          try {
            console.log(`DEBUG: Processing front design base64...`);
            const base64Data = item.front_design_preview.replace(/^data:image\/\w+;base64,/, '');
            const binaryStr = atob(base64Data);
            const buffer = new Uint8Array(binaryStr.length);
            for (let i = 0; i < binaryStr.length; i++) {
              buffer[i] = binaryStr.charCodeAt(i);
            }
            
            const fileName = `${order_id}/front_${item.id}.png`;
            console.log(`DEBUG: Uploading front design to ${fileName}...`);
            const { error: uploadError } = await supabaseClient.storage.from('qikink-designs').upload(fileName, buffer, { contentType: 'image/png', upsert: true });
            if (!uploadError) {
              const { data } = supabaseClient.storage.from('qikink-designs').getPublicUrl(fileName);
              finalFrontDesignUrl = data.publicUrl;
              finalFrontMockupUrl = data.publicUrl;
              console.log(`DEBUG: Front design uploaded successfully. URL: ${finalFrontDesignUrl}`);
            } else {
               console.error("DEBUG: Supabase Storage Upload Error (Front):", uploadError);
            }
          } catch (e) {
            console.error("DEBUG: Failed to process front design base64", e);
          }
        }
      }
      
      // Fallback for Back Print URL if it exists
      if (item.back_print_url && !item.back_design_preview) {
         finalBackDesignUrl = item.back_print_url;
         finalBackMockupUrl = item.back_mockup_url || item.back_print_url;
      }

      // Check Back Design
      if (item.back_design_preview) {
         if (item.back_design_preview.startsWith('http')) {
           finalBackDesignUrl = item.back_design_preview;
           finalBackMockupUrl = item.back_design_preview;
         } else {
          try {
            console.log(`DEBUG: Processing back design base64...`);
            const base64Data = item.back_design_preview.replace(/^data:image\/\w+;base64,/, '');
            const binaryStr = atob(base64Data);
            const buffer = new Uint8Array(binaryStr.length);
            for (let i = 0; i < binaryStr.length; i++) {
              buffer[i] = binaryStr.charCodeAt(i);
            }
            
            const fileName = `${order_id}/back_${item.id}.png`;
            console.log(`DEBUG: Uploading back design to ${fileName}...`);
            const { error: uploadError } = await supabaseClient.storage.from('qikink-designs').upload(fileName, buffer, { contentType: 'image/png', upsert: true });
            if (!uploadError) {
              const { data } = supabaseClient.storage.from('qikink-designs').getPublicUrl(fileName);
              finalBackDesignUrl = data.publicUrl;
              finalBackMockupUrl = data.publicUrl;
              console.log(`DEBUG: Back design uploaded successfully. URL: ${finalBackDesignUrl}`);
            } else {
               console.error("DEBUG: Supabase Storage Upload Error (Back):", uploadError);
            }
          } catch (e) {
            console.error("DEBUG: Failed to process back design base64", e);
          }
        }
      }

      // Fallbacks in case of upload failure or empty design
      if (!finalFrontDesignUrl) {
         finalFrontDesignUrl = "https://sgp1.digitaloceanspaces.com/cdn.qikink.com/erp2/assets/designs/83/1696668376.jpg";
         finalFrontMockupUrl = "https://sgp1.digitaloceanspaces.com/cdn.qikink.com/erp2/assets/designs/83/1696668376.jpg";
      }
      
      qikinkItems.push({
        sku: "MVnHs-Wh-S", // Exact SKU from the successful cURL payload
        quantity: parseInt(item.quantity, 10) || 1,
        price: parseFloat(item.price) || 0,
        search_from_my_products: 0,
        print_type_id: 1, // 1 = DTG (Direct to Garment)
        designs: [
          {
            design_code: `CUST-FR-${orderData.id.split('-')[0]}`,
            placement_sku: "fr",
            mockup_link: finalFrontMockupUrl,
            design_link: finalFrontDesignUrl,
            width_inches: 10,
            height_inches: 10
          },
          ...(finalBackDesignUrl ? [{
            design_code: `CUST-BK-${orderData.id.split('-')[0]}`,
            placement_sku: "bk",
            mockup_link: finalBackMockupUrl,
            design_link: finalBackDesignUrl,
            width_inches: 10,
            height_inches: 10
          }] : [])
        ]
      });
    }

    // 4. Construct Qikink Payload
    const qikinkPayload = {
      order_number: `ORD${orderData.id.split('-')[0]}`,
      qikink_shipping: 1, 
      gateway: 'Prepaid', 
      total_order_value: parseFloat(orderData.total) || 0,
      shipping_address: {
        first_name: address.full_name?.split(' ')[0] || "Customer",
        last_name: address.full_name?.split(' ').slice(1).join(' ') || "",
        address1: `${address.address_line} ${address.landmark || ''}`.trim(),
        city: address.city,
        province: address.state,
        country_code: "IN",
        zip: parseInt(address.pincode, 10) || 0,
        phone: address.phone,
        email: "customer@example.com"
      },
      line_items: qikinkItems
    };

    // 5. Send to Qikink API
    console.log("DEBUG: Qikink Payload being sent:");
    console.log(JSON.stringify(qikinkPayload, null, 2));
    
    const qikinkResponse = await fetch('https://sandbox.qikink.com/api/order/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'ClientId': qikinkClientId,
        'Accesstoken': accessToken
      },
      body: JSON.stringify(qikinkPayload)
    });

    const qikinkData = await qikinkResponse.json();

    if (!qikinkResponse.ok || qikinkData.error) {
      await supabaseClient
        .from('orders')
        .update({ printful_sync_status: 'failed' }) // Reusing this column name for now, or you can rename it later
        .eq('id', order_id);

      throw new Error(`Qikink API Error: ${JSON.stringify(qikinkData)}`);
    }

    // 5. Success! Update Supabase
    await supabaseClient
      .from('orders')
      .update({ 
        printful_sync_status: 'success'
      })
      .eq('id', order_id);

    return new Response(
      JSON.stringify({ success: true, qikink_data: qikinkData }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error: any) {
    console.error("Qikink Sync Error:", error.message);
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
