// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
var z="<div class='checkbox'><label for='version_bs_1_active'><input name='version[bs][1][active]' value='0' type='hidden'><input value='1' checked='checked' name='version[bs][1][active]' id='version_bs_1_active' type='checkbox'> Active</label></div>";

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function get_vers() {
    // sanity check
    var email_val;
    var pack_val;
    
  $( "#userver_package option:selected" ).each(function() {
      
        pack_val =$( this ).attr("value");
      
    });
  $( "select.select2-ajax option:selected" ).each(function() {
      
        email_val=$( this ).attr("value");
      
    });
    $.ajax({
        url : "/pack/vers_json/", // the endpoint
        dataType : "json", 
        type: "POST",
        data: {
          pack: pack_val,
          user_id: email_val,
        },
         // http method
         // data sent with the post request

        // handle a successful response
        success : function(json) {
          console.log("success");
             // remove the value from the input
        if (json.length>0)
          {

           needed_vers(json);
          }
        else
        {
          $('#vers_fields').html("Нет ни одной версии");
        }
        
        
          },
        // handle a non-successful response
        error : function(xhr,errmsg,err) {
            console.log(errmsg);
            console.log(err);
            console.log(xhr.status + ": " + xhr.responseText); // provide a bit more info about the error to the console
        }
    });
};
var p;
function needed_vers(json)
{
     p=json;
   var out="";
   var form="<div class='checkbox'><label for='{{id}}'><input name='vers[{{id}}][allow]' value='0' type='hidden'><input value='1' {{checked}} name='vers[{{id}}][allow]' id='{{id}}' type='checkbox'> {{name}}</label></div>";

         var template= Handlebars.compile(form);


       var date= "<div class='form-group'><label class='control-label' for='vers[{{id}}][date]'>Дата загрузки</label><input placeholder='dd/mm/yyyy' class='form-control form-control datepicker' value='15.12.2016' name='vers[{{id}}][date]' id='date_{{id}}' type='text'></div>";
       var date_template= Handlebars.compile(date);
          for (i in json)
        {
          var obj=json[i];
          var str="";

          if (obj.allow)
          {
          	str='checked';

          }
          else
          {
          	str="";
          }
         
          var context =
           {name: obj.name,
           	checked: str,
           	id: obj.id,
           	zz: "z",
          };
          var res=template(context);
          var res_date=date_template(context);
         
          out+=res;
          out+=res_date;
          
          $('#vers_fields').html(out);
        }
        
       
       

};


get_vers();

$( "#userver_package").change(
    
  get_vers
);
  
  $( "select.select2-ajax").change(
    
  get_vers
);

