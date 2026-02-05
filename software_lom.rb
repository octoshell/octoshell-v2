require 'net/ssh'
require 'csv'
# 2365
#SELECT  r.run_id, r.job_id, r.date, o.obj_id, o.object_path  from xalt_run  r  JOIN join_run_object as j on j.run_id = r.run_id JOIN xalt_object AS o on  o.obj_id = j.obj_id  WHERE r.job_id != 'unknown'  ORDER BY r.run_id   DESC    LIMIT 5;

# Путь
# Последнее изменение
# Владелец (не всегда информативно: root, practice)
# Есть ли версия в Octoshell (по пути на кластере, записанном в Octoshell)
# Содержимое поля "коммерческий" в Octoshell
# Есть ли пакет в Octoshell
# xalt: Когда использовался этот путь в последний раз (может быть неточно,
# может пути редко записываются в Tasc, спрошу потом  о тонкостях у Вадима Владимировича)
# Есть ли этот путь в modules (позволяет пользователям удобно компилировать и запускать)


# dirs = "/opt/software/* /opt/ccoe/*"
dirs = [
  "/opt/",
 # "/opt/software/",
 # "/opt/ccoe/",
 # # "/opt/intel/",
 # "/opt/cuda/",
 # "/opt/rh/",
 # # "/opt/extra",
 # "/opt/mpi/",
 # # "/opt/intel",
 # # "/opt/xalt/",
 # "/opt/make/",
 # # "/opt/pgi/",
 # # "/opt/pgi",
 # "/opt/nec/",
 # # "/opt/nvidia/",
 # # "/opt/Intel/",
 # "/opt/mellanox/",
 # "/opt/slurm/",
 # "/opt/toolworks/",
 # "/opt/xalt2/"
].map { |d| "#{d}*" }.join(' ')

LOM_ID = 5
puts dirs

def extract_paths(output, var, prefix = nil)
  paths = []

  # Handle both Lua and Tcl style syntax
  output.scan(/(?:prepend|append)_path\s*\(?\s*["']?#{var}["']?\s*,?\s*["']?(.+?)["']?\s*\)?[\s;]/).each do |(path)|
    # expanded = expand_variables(path, prefix)
    paths << path unless path.empty?
  end

  output.scan(/(?:setenv|setenv)\s*\(?\s*["']?#{var}["']?\s*,?\s*["']?(.+?)["']?\s*\)?[\s;]/).each do |(value)|
    # expanded = expand_variables(value, prefix)
    paths += value.split(':').reject(&:empty?)
  end

  # Traditional module syntax
  output.scan(/(?:prepend|append)-path\s+#{var}\s+(.+?)\s*(?:$|;|\n)/).each do |(path)|
    # expanded = expand_variables(path, prefix)
    paths << path unless expanded.empty?
  end

  output.scan(/setenv\s+#{var}\s+(.+?)\s*(?:$|;|\n)/).each do |(value)|
    # expanded = expand_variables(value, prefix)
    paths += value.split(':').reject(&:empty?)
  end

  paths.uniq
end

def module_files
  output = nil
  Net::SSH.start('lom') do |ssh|
    result = ssh.exec!('module -t spider')
    v = nil
    output = result.split("\n").map do |line|
        v = line
        content = ssh.exec!("module show #{v}")
        module_file = content.split("\n")[1][0...-1].strip
        paths = (extract_paths(content, /[^"]+/)).map do |path|
          path.squeeze(' ').squeeze('/')
        end
        e = [v, module_file, paths]
        puts e.inspect
        e
    end
  end
  output.compact
end


def index_of_char(str, char, n)
  res = str.chars.zip(0..str.size).select { |a,b| a == char }
  res[n]&.last
end
# out = module_files
# File.open('mod.dump', 'w') { |f| f.write(YAML.dump(out)) }
lmods = YAML.load File.read('mod.dump').to_s

# lmod_paths = lmods.map(&:third).flatten.map do |path|
#   next unless path.include?('/')
#
#   last_words = %w[bin include]
#   result = nil
#   last_words.each do |word|
#     result = path[..-(word.length) - 1] if path[-(word.length)..] == word
#   end
#   result
# end.compact

# pp lmod_paths
#
# exit

def forbidden_dir?(a, dirs)
  a = a.split('/')[1..]
  dirs.any? do |dir|
    res = true
    [a.count, dir.count].min.times do |i|
      res &&= (a[i] == dir[i])
    end
    res
  end


end

xalt_dirs = CSV.read('xalt_data.csv', col_sep: "\t")[1..].group_by(&:first)


forbidden_dirs = File.read('forbidden_dirs.txt').to_s.split("\n")
                     .map { |p| p.split(/\s/) }.map(&:first)
                     .map { |p| p.split('/')[1..] }

forbid_files = File.read('res_perm.out').to_s.split("\n")
                       .map { |p| p.split(':') }
                       .select { |p| p.count > 1 }


package_names = Pack::Package.all.map(&:name)
version_path = Pack::Version.includes(:options)
                            .joins(:clustervers)
                            .where('pack_clustervers.core_cluster_id = ?', LOM_ID)
                            .select('pack_versions.*,  pack_clustervers.path AS lom_path')
                            .map do |v|
                              path = v['lom_path']
                              path = path[0...-1] if path[-1] == '/'
                              [path, v]
                            end.to_h
# pp version_path.keys
# exit
array = nil
results = []
dirs_array = [dirs]
Net::SSH.start('lom') do |ssh|
  # List directories in the current path
  while dirs_array.any?
    dirs = dirs_array.shift
    result = ssh.exec!("sudo stat -c \"%y|%U|%n|%F|%G\" --  #{dirs}")
    array = result.split("\n").map do |row|
      splitted = row.split('|')
      {
        group_owner: splitted[4],
        type: splitted[3],
        path: splitted[2],
        owner: splitted[1],
        last_update: splitted[0].split(/\s+/).first
      }
    end
    array.each do |e|

      if [
        "/opt/software",
        "/opt/ccoe",
        "/opt/intel",
        "/opt/cuda",
        "/opt/rh",
        "/opt/mpi",
        "/opt/make",
        # "/opt/pgi",
        "/opt/nec",
        # "/opt/nvidia",
        "/opt/mellanox",
        "/opt/slurm",
        '/opt/software/hdf5',
        '/opt/software/lammps',
        '/opt/software/MATLAB',
        '/opt/ccoe/namd',
        "/opt/autoconf",
        "/opt/automake",


      ].include? e[:path]
        dirs_array << "#{e[:path]}/*"
        next
      end

      if version = version_path[e[:path]]
        e.merge!(
          octo_version: version.name,
          commercial: version.options.detect { |o| o.options_category&.name_ru == 'Коммерческий' ||
            o.name_ru == 'Коммерческий' }&.readable_value
        )
      end

      lmod_versions = lmods.select do |v|
        v[2].any? do |path|
          next(false) if path.length < 2

          a = e[:path].split('/')
          b = path.split('/')
          res = true
          [a.count, b.count].min.times do |i|
            res &&= (a[i] == b[i])
          end
          res
        end
      end

      e[:lmods] = if ['/opt/mpi/wrappers', '/opt/mellanox/mxm'].include? e[:path]
                    '-----'
                  else
                    lmod_versions.map(&:first).join(' ')
                  end
      #puts e[:path]
      #puts ssh.exec!("sudo find #{e[:path]} ! -perm -o=r | head -n 1")
      forbid_files_any  = forbid_files.detect { |p| e[:path].include? p[0] }
      # puts e[:path]
      # puts forbid_files_any

      e[:forbid] = if forbid_files_any || forbidden_dir?(e[:path], forbidden_dirs)
                      'да'
                    else
                      'нет'
                    end
      results << e
    end
  end
end
#ERROR 3 (HY000) at line 1: Error writing file '/var/tmp/MYF2mC2a' (Errcode: 28)

results.each do |result|
  cur_dirs = xalt_dirs[result[:path] + '/']
  unless cur_dirs
    puts result[:path]
    next
  end
  %w[2023 2024 2025].each do |y|
    result[:"#{y}_count"] = cur_dirs.detect { |row| row[3] == y }&.second
  end
  result[:xalt_last] = cur_dirs.reject{ |r| r[3] == 'NULL' }.map(&:third).max
end

def output_array(array)
  CSV.open("packets.csv", "w") do |csv|
    csv << ["Путь", "Последнее изменение", 'Есть файлы без доступа на чтение',
      'Последний запуск', 'Запусков в 2023', 'Запусков в 2024', 'Запусков в 2025',
      'ПО для рассмотрения?', 'Пакет', 'Версия', 'Описание пакета',
      'Модули', 'Тип', 'Владелец', 'Группа',
      'Версия в Octoshell', 'Коммерческий(Octoshell)']
    array.sort_by{ |e| e[:path]  }.each do |e|
      # puts e.inspect.red
      # exit
      csv << %i[path last_update forbid xalt_last 2023_count 2024_count 2025_count
        n n n n lmods type owner group_owner
        octo_version commercial].map { |key| e[key] }
    end
  end
end

output_array(results)
# pp array
