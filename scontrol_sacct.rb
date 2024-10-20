login = 'andrejpaokin_1977'
key_path =  '~/.ssh/hpc-acad2018-218'

def fetch_field(string, field)
  /#{field}=(\S+)/ =~ string
  $1
end

con = Net::SSH.start('lomonosov2.parallel.ru',
  login,
  keys: [key_path])

scontrol = con.exec!('sudo /opt/slurm/15.08.1/bin/scontrol  -o -d show job')

job_ids = scontrol.split("\n").map do |string|
  fetch_field(string, 'JobId')
end
sacct = con.exec!("sudo /opt/slurm/15.08.1/bin/sacct    -j #{job_ids.join(',')}   --format='jobid,Nnodes,Start,End'  -X -L")
           .split("\n")[2..].map { |str| str.split(/\s+/) }
res = []
not_equal = []
states = []
scontrol.split("\n").each do |string|
  job_id = fetch_field(string, 'JobId')
  num_nodes = fetch_field(string, 'NumNodes')
  if num_nodes.include?('-')
    node_array = num_nodes.split('-')
    if node_array[0] != node_array[1]
      not_equal << string
      next
    else
      num_nodes = node_array[0]
    end
  end
  if sacct.detect { |row| row[0] == job_id }[1] != num_nodes
    # res << string
    puts "#{num_nodes} #{fetch_field(string, 'JobState')}"
    puts string
    puts sacct.detect { |row| row[0] == job_id }.inspect
    puts "---"
    # exit(0)
  else
    # puts string
    # puts "#{num_nodes} #{fetch_field(string, 'JobState')}"
  end
end

# puts res
# puts not_equal
