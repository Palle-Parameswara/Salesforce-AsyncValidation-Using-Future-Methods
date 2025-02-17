# Salesforce-AsyncValidation-Using-Future-Methods

**External website used**: [Phone Validation API Tester](https://app.abstractapi.com/api/phone-validation/tester)

---

## **Future Methods Advantages and Disadvantages**

### **Advantages**:
- **Asynchronous Processing**: Future methods allow non-blocking, asynchronous execution, improving performance and reducing delays in trigger execution.
- **Governor Limits**: Future methods bypass synchronous callout limits, allowing API calls to be made without blocking the trigger’s execution.
- **Simple to Implement**: `@future(callout=true)` is easy to implement for making callouts asynchronously without complex logic.
- **Improved API Management**: Helps manage API call limits by offloading callouts to the background.

### **Disadvantages**:
- **Unpredictable Execution Timing**: Future methods run asynchronously, so you can’t guarantee when the API call will be processed, which may affect timing for dependent operations.
- **Governor Limits for Future Calls**: Limited to **50 future method calls** per transaction, which may be a bottleneck for large datasets.
- **Data Consistency Issues**: Future methods are outside the trigger transaction, meaning failures won’t roll back, potentially causing inconsistent data.
- **Debugging Complexity**: It can be harder to debug future methods due to their asynchronous nature.
- **No Job Chaining**: Future methods don’t support chaining jobs or passing data between future calls, unlike Queueable Apex.

---

## **Step-by-Step Guide**:

### **Step 1: Create External Credentials (Custom)**

External Credentials are used in Salesforce to store the credentials for an external service, typically used for integration. You can define **External Credentials** for services like phone/email validation APIs.

#### **Steps to Create External Credentials**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon at the top right and select **Setup**.
   
2. **Search for External Credentials**:
   - In the Quick Find box, type **"External Credentials"** and select **External Credentials** under **Security**.

3. **Create New External Credential**:
   - Click **New** to create a new External Credential.
   - Name it something like **Phone_Validation_API_Credentials** or **Email_Validation_API_Credentials**, depending on the service you’re configuring.

4. **Choose the Type**:
   - For Phone Validation API and Email Validation API, you will likely choose **Custom** for your authentication type.

5. **Fill Out Required Information**:
   - **Principal Type**: Select **Named Principal** if you are using a single set of credentials for the entire org.

6. **Save**:
   - After filling in the required fields, click **Save** to create the external credential.

![image](https://github.com/user-attachments/assets/8e38030c-8785-462d-80f4-6091595bf99d)
![image](https://github.com/user-attachments/assets/16dfee29-2274-41db-bf0c-e98406d7545f)

---

### **Step 2: Create Named Credentials**

Named Credentials store authentication settings securely and are linked to an external service. These credentials will be used to interact with the phone/email validation APIs.

#### **Steps to Create Named Credentials**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon and select **Setup**.
   
2. **Search for Named Credentials**:
   - In the Quick Find box, type **"Named Credentials"** and select **Named Credentials** under **Security**.

3. **Create New Named Credential**:
   - Click **New Named Credential**.

4. **Fill Out Named Credential Information**:
   - **Label**: Give it a name like **Phone_Validation_API**.
   - **Name**: This should automatically fill in when you type the label.
   - **URL**: Enter the endpoint URL for the Phone Validation or Email Validation API (e.g., `https://api.example.com`).
   - **Authentication Protocol**: Choose the appropriate authentication method (e.g., **No Authentication**, **OAuth**, **Basic Authentication**).
     - If you're using **OAuth 2.0**, select **OAuth 2.0** and configure the **Consumer Key**, **Consumer Secret**, etc., according to the external service's requirements.

5. **Link External Credentials**:
   - In the **External Credential** section, choose the **External Credential** you created in **Step 1**.

6. **Save the Named Credential**.

![image](https://github.com/user-attachments/assets/53c6972f-f004-4e7d-8956-4d1b9c99cb05)
![image](https://github.com/user-attachments/assets/956b5fc4-2aa5-45b5-8317-fcd39a6702cc)

---

### **Step 3: Create Principals for External Credentials**

In Salesforce, **Principals** refer to the identity used for accessing external systems. You’ll need to create a **Principal** for the **External Credentials** to assign it to the **Named Credential**.

#### **Steps to Create Principals**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon and select **Setup**.

2. **Search for Principal**:
   - In the Quick Find box, type **"Principals"**.

3. **Create a New Principal**:
   - Click **New** to create a new principal.

4. **Fill Out the Principal Information**:
   - **Label**: Give it a name, such as **PhoneValidation_Principal**.
   - **Name**: This should automatically populate when you type the label.
   - **Principal Type**: Choose the appropriate **Principal Type** (e.g., **Named Principal** for a shared access identity).
   - **Authentication Method**: Choose the method matching your integration (e.g., **Basic Authentication**, **OAuth**).

5. **Associate Principal with External Credential**:
   - Link the Principal to the **External Credential** you created earlier in **Step 1**.

6. **Save the Principal**.

![image](https://github.com/user-attachments/assets/76db1dc5-131a-44d0-8720-e872de76188f)

---

### **Step 4: Assign the External Credential Principal to Permission Sets**

Now that you’ve created the **External Credentials**, **Named Credentials**, and **Principals**, the next step is to assign them to the **Permission Set** so that users can access these external services securely.

#### **Steps to Assign Credentials to a Permission Set**:
1. **Go to Setup**:
   - In Salesforce, click the gear icon and select **Setup**.

2. **Search for Permission Sets**:
   - In the Quick Find box, type **"Permission Sets"** and select **Permission Sets**.

3. **Create a New Permission Set**:
   - Click **New** to create a new Permission Set.
   - Name the Permission Set (e.g., **API Access for Validation**).
   - Set the **User License** according to your use case.

4. **Assign Permission Set to External Credentials**:
   - Under **System Permissions**, click **Edit**.
   - Scroll down and find **"API Enabled"**. Ensure this permission is checked for the users who need access to the external credentials.

5. **Assign the Named Credentials**:
   - Scroll down to **Apex Class Access** and ensure that the **Apex Classes** for your validation methods (like **PhoneValidationQueueable** and **EmailValidationQueueable**) are selected.

6. **Save the Permission Set**.

7. **Assign the Permission Set to Users**:
   - Go to the **Permission Set** detail page and click **Manage Assignments**.
   - Click **Add Assignments**, select the users you want to assign the permission set to, and click **Assign**.

---

### **Step 5: Create Custom Fields for Phone and Email Validation**

Now, you'll need to create custom fields in the **Contact** object to store the validation details.

#### **For Phone Validation**:
1. Go to **Setup** → **Object Manager** → **Contact** → **Fields & Relationships**.
2. Click **New Field**.
3. Create the following fields:
   - **Phone Validation Status (Phone_Validation_Status__c)**: Type: **Checkbox** (Valid/Invalid).
   - **Phone Type (Phone_Type__c)**: Type: **Picklist** (e.g., Mobile, Landline, VoIP).
   - **Phone Country (Phone_Country__c)**: Type: **Text** (Country name).
   - **Phone Location (Phone_Location__c)**: Type: **Text** (City or Region).

#### **For Email Validation**:
1. Go to **Setup** → **Object Manager** → **Contact** → **Fields & Relationships**.
2. Click **New Field**.
3. Create the following fields:
   - **Email Deliverability (Email_Validation_Status__c)**: Type: **Picklist** (Valid/Invalid).
   - **Quality Score (Quality_Score__c)**: Type: **Decimal** (0-100 scale).

Add all these fields to the **layout** for the **Contact** object.

![image](https://github.com/user-attachments/assets/fe5ef553-a923-43f3-95a3-8d7219fa97dd)

---

### **Step 6: Update the Contact Validation Controller with Future Methods**

Here’s the `ContactValidationController` class with `@future(callout=true)` methods:

(Include the code for future methods as shown previously in the original response.)

---

### **Step 7: Trigger to Call Future Methods**

Here’s the `ContactValidationTrigger` to call the future methods:

(Include the code for the trigger as shown previously in the original response.)

---

### **References**:
- [Phone Validation API - Abstract API](https://app.abstractapi.com/api/phone-validation/tester)
- [YouTube Tutorial](https://www.youtube.com/watch?v=sE6MX8vz1Y0)

