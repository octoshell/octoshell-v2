var root = typeof exports !== 'undefined' && exports !== null ? exports : this;
base_url = '/cloud_computing/admin/item_kinds/';

function handle_ajax_error(jqXHR, textStatus, errorThrown) {
  show_flash('danger',jqXHR.responseText);
  $('#item_kinds_tree').jstree("refresh");
}

function handle_ajax_success(data) {
  show_flash('success', data);
  $('#item_kinds_tree').jstree("refresh");
}


function get_parent(node_data){
  if(parent == '#'){
    parent = null;
  }
}
// var Spree = 'aloha';
// $.jstree.defaults.dnd.check_while_dragging = false;

function handle_move(e, node_data) {
  console.log(node_data);
  var parent = node_data.parent;
  if(parent == '#'){
    parent = null;
  }
  $.ajax({
    type: 'POST',
    dataType: 'text',
    url: base_url + '/' + node_data.node.id,
    data: {
      _method: 'put',
      'item_kind[parent_id]': parent,
      'item_kind[child_index]': node_data.position,
    },
  }).done(handle_ajax_success).fail(handle_ajax_error);
}

function handle_create(e,node) {
  console.log('handle_create');

  function rename_after_create(e, node){
    console.log('inside_handle_create');
    $(this).unbind('rename_node.jstree', rename_after_create);
    $(this).bind('rename_node.jstree', handle_rename);
    // console.log(node);
    //
    // console.log(node.new_name);
    // console.log(node.parent_id);
    var parent = node.node.parent;
    if(parent == '#'){
      parent = null;
    }
    $.ajax({
      type: 'POST',
      dataType: 'text',
      url: base_url.toString(),
      data: {
        'item_kind[name]': node.text,
        'item_kind[parent_id]': parent,
        'item_kind[child_index]': position,
      }
    }).done(handle_ajax_success).fail(handle_ajax_error);
  }
  var position = node.position;
  $(this).unbind('rename_node.jstree', handle_rename);
  $(this).bind('rename_node.jstree', rename_after_create);

}

function handle_rename(e, node_data) {
  var url = base_url + '/' + node_data.node.id;
  $.ajax({
    type: 'POST',
    dataType: 'text',
    url: url,
    data: {
      _method: 'put',
      'item_kind[name]': node_data.text,
    }
  }).success(handle_ajax_success).fail(handle_ajax_error);
}

function handle_delete(e, node_data) {
  var url = base_url + '/' + node_data.node.id;
  if (confirm('Do u want to delete the ' + node_data.node.text +  ' item?')) {
    $.ajax({
      type: 'POST',
      dataType: 'text',
      url: url,
      data: {
        _method: 'delete',
      }
    }).done(handle_ajax_success).fail(handle_ajax_error);
  } else {
    $('#item_kinds_tree').jstree("refresh");
  }
}


root.setup_item_kind_tree = function () {
  var item_kinds_tree = $('#item_kinds_tree');
  item_kinds_tree.jstree({ 'core' : {
    'data' : {
      'url' : base_url + 'jstree/'
    },
    'force_text' : true,
    'check_callback' : true,
    'themes' : {
      'responsive' : false
    }
  },
  'contextmenu':{
    'items': item_kinds_menu
  },
  "plugins" : ["dnd", 'wholerow','state', 'contextmenu']
}).on('move_node.jstree', handle_move).bind('create_node.jstree', handle_create)
  .bind('rename_node.jstree', handle_rename).bind('delete_node.jstree', handle_delete);



     // item_kinds_tree.bind("loaded.jstree", function () {
     //     item_kinds_tree.jstree("open_all");
     // });


};
