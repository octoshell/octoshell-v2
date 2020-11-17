var root = typeof exports !== 'undefined' && exports !== null ? exports : this
base_url = '/cloud_computing/admin/item_kinds/';
var Translations = {
  'add': 'add',
  'rename': 'rename',
  'remove': 'remove',
  'edit': 'edit'
}
root.item_kinds_menu = function (obj, context,p3) {
  var item_kinds_tree = $('#item_kinds_tree').jstree(true);

  console.log(obj);
  console.log(context);

  var editUrl = base_url +  + obj.id + '/edit';
  return {
    create: {
      label: '<span class="glyphicon glyphicon-plus"></span> ' + Translations.add,
      action: function () {

        // return item_kinds_tree.edit(obj);
        $("#item_kinds_tree").jstree("create_node", obj, null, "last", function (node) {
          this.edit(node);
        });

        // return item_kinds_tree.create_node(obj,null,null,'last', function (node) {
        //   item_kinds_tree.edit(node);
        // });
      }
    },
    rename: {
      label: '<span class="glyphicon glyphicon-pencil"></span> ' + Translations.rename,
      action: function () {
        console.log(obj);
        console.log(this);

        return item_kinds_tree.edit(obj)
      }
    },
    remove: {
      label: '<span class="glyphicon glyphicon-trash"></span> ' + Translations.remove,
      action: function () {
        return item_kinds_tree.delete_node(obj)
      }
    },
    edit: {
      separator_before: true,
      label: '<span class="glyphicon glyphicon-cog"></span> ' + Translations.edit,
      action: function () {
        window.location = editUrl.toString()
        return window.location
      }
    }
  }
}
