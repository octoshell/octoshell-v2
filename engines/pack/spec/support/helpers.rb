module PackHelpers

  def build_packs(n,user)
    packages = []
    n.times  do |i|
      package = Pack::Package.new(name: "name#{i}")
      n.times do |j|
        version = Pack::Version.new(name: "name#{i}_#{j}")
        version.accesses << Pack::Access.new(who: user)
        package.versions << version
      end

      packages << package
    end
    Pack::Package.import packages,recursive: true, validate: false
  end

  def access_with_status(overrides = nil)
    access = FactoryGirl.build(:access, overrides)
    access.save
    access
  end

  def access_with_status_without_validation(overrides = nil)
    access = FactoryGirl.build(:access, overrides)
    access.save(:validate => false)
    access
  end

  def jobs_array
    Pack::PackWorker.jobs.map{ |h| h['args']  }
  end

  def expect_sidekiq_mailer arr
    puts jobs_array.inspect
    expect(jobs_array).to eq arr
    arr.each do |a|
      a = a - ["access_changed"]
      Pack::Mailer.access_changed(a[0], *( a.drop(1)  ) ) .deliver!
    end
  end

  def login_capybara user
    visit '/auth/session/new'
      fill_in 'user_email',    with: user.email
      fill_in 'user_password', with: '123456'
      click_button 'Войти'
    end

    def jquery_regex
      page.execute_script(<<-eo)
        jQuery.expr[':'].regex = function(elem, index, match) {
        var matchParams = match[3].split(','),
          validLabels = /^(data|css):/,
          attr = {
              method: matchParams[0].match(validLabels) ?
                          matchParams[0].split(':')[0] : 'attr',
              property: matchParams.shift().replace(validLabels,'')
          },
          regexFlags = 'ig',
          regex = new RegExp(matchParams.join('').replace(/^\s+|\s+$/g,''), regexFlags);
        return regex.test(jQuery(elem)[attr.method](attr.property));
    }
    eo
    end

    def select2 select_id,option_text
    find("#select2-#{select_id}-container").click
    a = <<-eoruby
      $('#select2-#{select_id}-results').find('li').filter(function(){
      return $(this).text() === '#{option_text}';
      }).mouseup();
    eoruby
    page.execute_script(a)
  end

  def all_with_con(con)
    arr = []
    all(con).each do  |elem|
      if yield(elem)
        arr << elem
      end
    end
    arr
  end
  def get_all_cat_radio
    all(".select-auto")
  end
end
