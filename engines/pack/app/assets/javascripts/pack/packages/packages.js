// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function get_packs() {
    // sanity check
    var dict;
  $( "#search_deleted option:selected" ).each(function() {
        dict=
      {
        deleted : $( this ).attr("value"), 
      } ;
    });
    $.ajax({
        url : "/pack/packages_json/", // the endpoint
        dataType : "json", 
        type: "POST",
        data: {
          search: dict,
        },
         // http method
         // data sent with the post request

        // handle a successful response
        success : function(json) {
          console.log("success");
             // remove the value from the input
        if (json.length>0)
          {

            needed_packs(json);
          }
        else
        {
          $('#json-pack').html("Нет ни одного пакета");
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
function needed_packs(packages)
{
     p=packages;
   var out="<tr><th>Название</th><th>Стоимоcть</th><th></th></tr>";
           var button="<td><div class='btn-group pull-right'><a class='btn btn-default btn-sm' href='/pack/packages/{{num}}/edit'>Редактировать</a><button class='btn btn-default btn-sm dropdown-toggle' data-toggle='dropdown' type='button'><span class='caret'></span></button><ul class='dropdown-menu' role='menu'><li class='text-left'><a data-method='delete' data-confirm='Вы действительно хотите удалить пакет?' class='text-danger' href='/pack/packages/{{num}}'>Удалить</a></li></ul></div></td>";
         var template= Handlebars.compile(button);
         var link_source="  <a href='/pack/packages/{{num}}'>{{name}}</a>";
       var template_link= Handlebars.compile(link_source);          

          for (i in packages)
        {
          var obj=packages[i];
          var context = {num: obj.id};
          var res=template(context);
          var res_link=template_link({num: obj.id, name: obj.name});
          out+="<tr>"  + "<td>" +  res_link   + "</td>" + "<td>" +  obj.cost   + "</td>" + res + "</tr>";
          
          $('#json-pack').html(out);
        }
        
       
       

};


get_packs();

$( "#search_deleted").change(
    
  get_packs
);
  

