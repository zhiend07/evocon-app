exports.handler = async (event) => {
  const encodedUrl = event.queryStringParameters?.url;
  const auth = event.queryStringParameters?.auth;

  console.log('📍 Proxy called with URL:', encodedUrl);

  if (!encodedUrl || !auth) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Missing url or auth parameters' }),
      headers: { 'Access-Control-Allow-Origin': '*' }
    };
  }

  try {
    const apiUrl = decodeURIComponent(encodedUrl);
    
    console.log('🔗 Calling API:', apiUrl);

    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await response.text();

    return {
      statusCode: response.status,
      body: data,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        'Content-Type': 'application/json',
      },
    };
  } catch (error) {
    console.error('❌ Proxy error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
      headers: { 'Access-Control-Allow-Origin': '*' }
    };
  }
};