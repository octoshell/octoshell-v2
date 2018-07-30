# User.eager_load(:profile).all.each do |user|
#   profile = user.profile
#   email = user.email
#   full = (profile.first_name.to_s + profile.last_name.to_s + profile.middle_name.to_s).to_s
#   puts "#{full}|||#{email}" if full =~ /^[a-zA-Z]+$/ && !email['ru']
# end
emails_list = %w[
  releu@icloud.com
  sdf@sd.s
  ikmake9@gmail.com
  g.barakos@liverpool.ac.uk
  a@a.com
  jvary@iastate.edu
  gustavo.yepes@uam.es
  g.momferratos@gmail.com
  ali.dorostkar@it.uu.se
  difficultemailforcommunicat@gmail.com
  zavodszky@uva.nl
  cristiano.palomba@roma1.infn.it
  sartr14@yandex.ua
  zhangchao_china@outlook.com
  komatsu@tohoku.ac.jp
  luca.rei@ge.infn.it
  vardanyan@dwi.rwth-aachen.de
  jonathan.bull@it.uu.se
  zahed.allahyari@gmail.com
  o-watanabe@az.jp.nec.com
]
ActiveRecord::Base.transaction do
  User.all.each do |user|
    if emails_list.include? user.email
      user.language = 'en'
    else
      user.language = 'ru'
    end
    user.save!(validate: false)
  end
end
