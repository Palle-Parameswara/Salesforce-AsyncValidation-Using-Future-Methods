public class ContactValidationController {
    private static final String Phone_API_KEY = 'd90b7df724114ec59a326b81afca3e4e'; // Replace with your Phone actual API key
    private static final String Email_API_KEY = '2c507050a4ee45c3857780ddc2347f40'; // Replace with your Email actual API key

    // Future method for phone validation
    @future (callout=true)
    public static void validatePhoneNumberAsync(String contactId) {
        // Retrieve the phone number of the contact
        Contact contact = [SELECT Id, Phone FROM Contact WHERE Id = :contactId LIMIT 1];
        
        if (String.isEmpty(contact.Phone)) {
            return;  // No phone to validate
        }

        // Make the callout to the Phone Validation API
        String endpoint = 'callout:Phone_Number_Validation/v1/?api_key=' + Phone_API_KEY + '&phone=' + EncodingUtil.urlEncode(contact.Phone, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> phoneDetails = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            // Cast the 'country' field to Map to access the 'name' and 'code'
            Map<String, Object> countryDetails = (Map<String, Object>) phoneDetails.get('country');
            
            // Update the contact fields based on the phone validation response
            contact.Phone_Validation_Status__c = (Boolean) phoneDetails.get('valid');
            contact.Phone_Type__c = (String) phoneDetails.get('type');
            contact.Phone_Country__c = (String) countryDetails.get('name');
            contact.Phone_Location__c = (String) phoneDetails.get('location');
            update contact;
        } else {
            // Handle the error if the phone validation API fails
            System.debug('Phone Validation API Error: ' + res.getStatusCode());
        }
    }

    // Future method for email validation
    @future (callout=true)
    public static void validateEmailAsync(String contactId) {
        // Retrieve the email address of the contact
        Contact contact = [SELECT Id, Email FROM Contact WHERE Id = :contactId LIMIT 1];
        
        if (String.isEmpty(contact.Email)) {
            return;  // No email to validate
        }

        // Make the callout to the Email Validation API
        String endpoint = 'callout:Email_Validation/v1/?api_key=' + Email_API_KEY + '&email=' + EncodingUtil.urlEncode(contact.Email, 'UTF-8');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> emailDetails = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            // Update the contact fields based on the email validation response
            contact.deliverability__c = (String) emailDetails.get('deliverability');
            contact.Quality_Score__c = (String) emailDetails.get('quality_score');
            update contact;
        } else {
            // Handle the error if the email validation API fails
            System.debug('Email Validation API Error: ' + res.getStatusCode());
        }
    }
}