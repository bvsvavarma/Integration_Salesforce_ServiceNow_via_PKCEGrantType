public with sharing class ServiceNowAuthController {
    public static String ENDPOINT = 'https://dev318094.service-now.com/oauth_auth.do';
    public static String REDIRECT_URI = 'https://varma6-dev-ed.develop.my.salesforce.com/apex/ServiceNowAuthExchangePage';
    public static String CLIENT_ID = '597cdAAAAAAAAAAAAA0f0482';
    public static String CLIENT_SECRET = 'BBBBBBBBBBB';
    public static String CODE_VERIFIER = 'j8nCtIiF097HGwl9iBJi4JF_ByqQqaJvTnU7CeEofjc';
    public static String TOKEN_ENDPOINT = 'https://dev318094.service-now.com/oauth_token.do';
    public static String INCIDENT_ENDPOINT = 'https://dev318094.service-now.com/api/now/table/incident?sysparm_query=priority=1&sysparm_limit=10';

    @AuraEnabled
    public static String fetchAuthUrl(){
        //Creating Code Challange
        //Step1: Create code verifier
        String codeVerifier = CODE_VERIFIER; // generated from https://tonyxu-io.github.io/pkce-generator/
        
        //Step2:Encrypt the code verifier
        //Convert String to Blob
        Blob codeVerifierBlob = Blob.valueOf(codeVerifier);
        Blob cryptoDigest = Crypto.generateDigest('SHA-256', codeVerifierBlob);
        
        //Strp3: Encode the code verifier
        String codeChallenge = EncodingUtil.base64Encode(cryptoDigest)
                            .replace('+','-')
                            .replace('/','_')
                            .replace('=','')
                            .replace(' ','-');
        System.debug('codeChallenge'+codeChallenge);
        
        String authUrl = ENDPOINT +
        '?grant_type=authorization_code' +
        '&redirect_uri=' + REDIRECT_URI +
        '&client_id=' + CLIENT_ID +
        '&response_type=code' +
        '&state=' + 'HEY' +
        '&code_challenge=' + codeChallenge;
        
        return authUrl;
    }

    @AuraEnabled
    public static String exchangeAuthCodeForToken(String authCode){
        
        String requestBody ='grant_type=authorization_code'+
        '&code=' + EncodingUtil.urlEncode(authCode, 'UTF-8') +
        '&client_id=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') +
        '&client_secret=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8') +
        '&redirect_uri=' + EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8') +
        '&code_verifier=' + EncodingUtil.urlEncode(CODE_VERIFIER, 'UTF-8');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            Map<String, Object> responseMap = ( Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String accessToken = (String) responseMap.get('access_token');
            String incidentsInfo = getAllIncidents(accessToken);
            return incidentsInfo;
        }
        return 'Something went wong. Callout Failed';
       
    }

    @AuraEnabled
    public static String getAllIncidents(String accessToken){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(INCIDENT_ENDPOINT);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer '+ accessToken);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200){
            return response.getBody();
        }
        return 'callout Failed';
    }
}