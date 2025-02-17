trigger ContactValidationTrigger on Contact (before insert, before update) {
    for (Contact c : Trigger.new) {
        
        // Phone Validation: Check if the phone number field is not empty and has been updated
        if (c.Phone != null && (Trigger.isInsert || (c.Phone != Trigger.oldMap.get(c.Id).Phone))) {
            try {
                // Call the future method for phone validation
                ContactValidationController.validatePhoneNumberAsync(c.Id);
            } catch (Exception e) {
                System.debug('Phone Validation API Error: ' + e.getMessage());
            }
        }

        // Email Validation: Check if the email field is not empty and has been updated
        if (c.Email != null && (Trigger.isInsert || (c.Email != Trigger.oldMap.get(c.Id).Email))) {
            try {
                // Call the future method for email validation
                ContactValidationController.validateEmailAsync(c.Id);
            } catch (Exception e) {
                System.debug('Email Validation API Error: ' + e.getMessage());
            }
        }
    }
}