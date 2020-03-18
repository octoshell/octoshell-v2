Face::MyMenu.items_for(:admin_submenu) do
  if can?(:manage, :reports_engine)
    add_item('reports_engine', t("admin_submenu.reports_engine"),main_app.reports_path, 'reports/constructor')
  end
end
