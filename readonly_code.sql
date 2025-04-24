BEGIN
  IF APEX_AUTHORIZATION.IS_AUTHORIZED('Auditor') THEN
    -- Set application item to track read-only status
    apex_util.set_session_state('APP_IS_READ_ONLY', 'Y');
    
    -- Disable all form items globally via JavaScript injection
    apex_javascript.add_onload_code('
      function makeAppReadOnly() {
        // Check if APEX API is available (for 19.2+)
        if (typeof apex !== "undefined" && apex.item) {
          // Use APEX API to disable items
          apex.jQuery(".apex-item-text, .apex-item-select, .apex-item-textarea").each(function() {
            var itemId = apex.jQuery(this).attr("id");
            if (itemId) {
              // Extract the item name from the ID
              var nameMatch = itemId.match(/^(P\d+_\w+)$/);
              if (nameMatch) {
                try {
                  apex.item(nameMatch[1]).disable();
                } catch(e) {
                  // Fallback to jQuery if item API fails
                  apex.jQuery(this).attr("disabled", true);
                }
              } else {
                // If no match, use jQuery fallback
                apex.jQuery(this).attr("disabled", true);
              }
            }
          });
          
          // Disable date pickers using APEX API
          apex.jQuery(".apex-item-datepicker").each(function() {
            var itemId = apex.jQuery(this).attr("id");
            if (itemId) {
              try {
                apex.item(itemId).disable();
              } catch(e) {
                apex.jQuery(this).attr("disabled", true);
              }
            }
          });
        } else {
          // Fallback for older APEX versions
          $("input, select, textarea").attr("disabled", true);
          $(".apex-item-datepicker, .apex-item-popup-lov, .apex-item-group").attr("readonly", true).attr("disabled", true);
        }
        
        // Remove the date picker and LOV popup icons/triggers
        $(".a-Button.a-Button--calendar, .a-Button.a-Button--popupLOV").hide();
        
        // Disable rich text editors if present
        $(".apex-item-textarea.apex-item-has-rich-text-editor").attr("contenteditable", false);
        
        // Hide APEX action buttons based on text content
        apex.jQuery(".t-Button").each(function() {
          var buttonText = apex.jQuery(this).text().toLowerCase();
          
          if (buttonText.indexOf("edit") >= 0 || 
              buttonText.indexOf("create") >= 0 || 
              buttonText.indexOf("delete") >= 0 || 
              buttonText.indexOf("save") >= 0 || 
              buttonText.indexOf("add") >= 0 ||
              buttonText.indexOf("update") >= 0 ||
              buttonText.indexOf("remove") >= 0) {
            apex.jQuery(this).hide();
          }
        });
        
        // Disable all buttons except exact matches for Cancel and Back
        apex.jQuery(".t-Button").each(function() {
          var buttonText = apex.jQuery(this).text().trim().toLowerCase();
          if (buttonText !== "cancel" && buttonText !== "back") {
            if (typeof apex.widget !== "undefined" && apex.widget.button) {
              // Try to use APEX button API if available
              try {
                var buttonId = apex.jQuery(this).attr("id");
                if (buttonId) {
                  apex.widget.button("#" + buttonId).disable();
                } else {
                  apex.jQuery(this).attr("disabled", true);
                }
              } catch(e) {
                apex.jQuery(this).attr("disabled", true);
              }
            } else {
              apex.jQuery(this).attr("disabled", true);
            }
          }
        });
        
        // Use APEX API to disable any interactive report actions if available
        if (typeof apex.region !== "undefined") {
          apex.jQuery(".a-IRR").each(function() {
            var regionId = apex.jQuery(this).attr("id");
            if (regionId) {
              try {
                var region = apex.region(regionId);
                if (region && region.widget && region.widget.interactiveReport) {
                  region.widget.interactiveReport("option", "readonly", true);
                }
              } catch(e) {
                // Fallback to standard methods if API fails
              }
            }
          });
        }
        
        // Remove the clickable behavior from all interactive elements
        apex.jQuery(".apex-item-wrapper").css("pointer-events", "none");
      }
      
      // Execute immediately and also after any AJAX refreshes
      makeAppReadOnly();
      apex.jQuery(document).on("apexafterrefresh", function(){
        makeAppReadOnly();
      });
    ');
  END IF;
END;
