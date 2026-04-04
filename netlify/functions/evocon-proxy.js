exports.handler = async (event) => {
  try {
    // Récupérer les paramètres depuis l'URL
    const params = new URLSearchParams(event.rawQuery);
    const apiUrl = params.get('url');
    
    if (!apiUrl) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'URL parameter required' }),
      };
    }

    // Faire la requête à l'API Evocon
    const response = await fetch(decodeURIComponent(apiUrl));
    const data = await response.json();

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};