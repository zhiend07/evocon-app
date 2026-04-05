exports.handler = async (event) => {
  const apiUrl = event.queryStringParameters?.apiUrl;
  const auth = event.queryStringParameters?.auth;

  if (!apiUrl || !auth) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Missing apiUrl or auth parameters' }),
    };
  }

  try {
    const response = await fetch(apiUrl, {
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
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json',
      },
    };
  } catch (error) {
    console.error('Proxy error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};