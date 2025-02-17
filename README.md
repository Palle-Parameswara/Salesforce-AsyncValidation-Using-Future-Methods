# Salesforce-AsyncValidation-Using-Future-Methods
Step-by-Step Guide:
Step 1: Create External Credentials (Custom)
External Credentials are used in Salesforce to store the credentials for an external service, typically used for integration. You can define External Credentials for services like phone/email validation APIs.

Steps to Create External Credentials:
Go to Setup:
In Salesforce, click the gear icon at the top right and select Setup.
Search for External Credentials:
In the Quick Find box, type "External Credentials" and select External Credentials under Security.
Create New External Credential:
Click New to create a new External Credential.
Name it something like Phone_Validation_API_Credentials or Email_Validation_API_Credentials, depending on the service you’re configuring.
Choose the Type:
For Phone Validation API and Email Validation API, you will likely choose Custom for your authentication type.
Fill Out Required Information:
Authentication Protocol: Depending on the API, select either OAuth 2.0, No Authentication, or other available methods.
Principal Type: Select Named Principal if you are using a single set of credentials for the entire org.
Save:
After filling in the required fields, click Save to create the external credential.


Step 2: Create Named Credentials
Named Credentials store authentication settings securely and are linked to an external service. These credentials will be used to interact with the phone/email validation APIs.
Steps to Create Named Credentials:
Go to Setup:
In Salesforce, click the gear icon and select Setup.
Search for Named Credentials:
In the Quick Find box, type "Named Credentials" and select Named Credentials under Security.
Create New Named Credential:
Click New Named Credential.
Fill Out Named Credential Information:
Label: Give it a name like Phone_Validation_API.
Name: This should automatically fill in when you type the label.
URL: Enter the endpoint URL for the Phone Validation or Email Validation API (e.g., https://api.example.com).
Authentication Protocol: Choose the appropriate authentication method (e.g., No Authentication, OAuth, Basic Authentication).
If you're using OAuth 2.0, select OAuth 2.0 and configure the Consumer Key, Consumer Secret, etc., according to the external service's requirements.
Link External Credentials:
In the External Credential section, choose the External Credential you created in Step 1.
Save the Named Credential.

Step 3: Create Principals for External Credentials
In Salesforce, Principals refer to the identity used for accessing external systems. You’ll need to create a Principal for the External Credentials to assign it to the Named Credential.
Steps to Create Principals:
Go to Setup:
In Salesforce, click the gear icon and select Setup.
Search for Principal:
In the Quick Find box, type "Principals".
Create a New Principal:
Click New to create a new principal.
Fill Out the Principal Information:
Label: Give it a name, such as PhoneValidation_Principal.
Name: This should automatically populate when you type the label.
Principal Type: Choose the appropriate Principal Type (e.g., Named Principal for a shared access identity).
Authentication Method: Choose the method matching your integration (e.g., Basic Authentication, OAuth).
Associate Principal with External Credential:
Link the Principal to the External Credential you created earlier in Step 1.
Save the Principal.

Step 4: Assign the External Credential Principal to Permission Sets
Now that you’ve created the External Credentials, Named Credentials, and Principals, the next step is to assign them to the Permission Set so that users can access these external services securely.
Steps to Assign Credentials to a Permission Set:
Go to Setup:
In Salesforce, click the gear icon and select Setup.
Search for Permission Sets:
In the Quick Find box, type "Permission Sets" and select Permission Sets.
Create a New Permission Set:
Click New to create a new Permission Set.
Name the Permission Set (e.g., API Access for Validation).
Set the User License according to your use case.
Assign Permission Set to External Credentials:
Under System Permissions, click Edit.
Scroll down and find "API Enabled". Ensure this permission is checked for the users who need access to the external credentials.
Assign the Named Credentials:
Scroll down to Apex Class Access and ensure that the Apex Classes for your validation methods (like PhoneValidationQueueable and EmailValidationQueueable) are selected.
Save the Permission Set.
Assign the Permission Set to Users:
Go to the Permission Set detail page and click Manage Assignments.
Click Add Assignments, select the users you want to assign the permission set to, and click Assign.

Step 5: Create Custom Fields for Phone and Email Validation
Now, you'll need to create custom fields in the Contact object to store the validation details.
For Phone Validation:
Go to Setup → Object Manager → Contact → Fields & Relationships.
Click New Field.
Create the following fields:
Phone Validation Status (Phone_Validation_Status__c): Type: Checkbox(Valid/Invalid).
Phone Type (Phone_Type__c): Type: Picklist (e.g., Mobile, Landline, VoIP).
Phone Country (Phone_Country__c): Type: Text (Country name).
Phone Location (Phone_Location__c): Type: Text (City or Region).
For Email Validation:
Go to Setup → Object Manager → Contact → Fields & Relationships.
Click New Field.
Create the following fields:
Email Deliverability (Email_Validation_Status__c): Type: Picklist (Valid/Invalid).
Quality Score (Quality_Score__c): Type: Text (0-100 scale).

Step 6: Update the Contact Validation Controller with Future Methods

Here’s the #ContactValidationController class with @future(callout=true) methods:


Step 7: Trigger to Call Future Methods
#ContactValidationTrigger 
