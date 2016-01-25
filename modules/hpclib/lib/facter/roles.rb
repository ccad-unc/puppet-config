# Fact: myroles
# Purpose: Returns the node roles in a HPC cluster
#
# Fact: hohastherole 
# Purpose: Returns the association role => nodes in a HPC cluster

###### Initialize Hiera backend #######
require 'hiera'

# TODO: add json support

options = {
  :default => nil,
  :config  => File.join(Hiera::Util.config_dir, 'hiera.yaml'),
  :scope   => {},
  :key     => nil,
  :verbose => false,
  :resolution_type => :priority
}

begin
  hiera = Hiera.new(:config => options[:config])
  rescue Exception => e
  if options[:verbose]
    raise
  else
    STDERR.puts "Failed to start Hiera: #{e.class}: #{e}"
    exit 1
  end
end

unless options[:verbose]
  Hiera.logger = "noop"
end

########################################

myroles = Array.new 
hname = `hostname -s`.chomp 
whohastherole = Hash.new 
options[:key] = "roles"
allroles = hiera.lookup(options[:key], options[:default], options[:scope], nil, options[:resolution_type])

allroles.each do | key,value|
  whohastherole[key] = Array.new
  nodes = value.split(',') if value != nil
  hosts = Array.new
  if nodes != nil
    nodes.each do | element|
      ### Node is a range ###
      isrange = element.to_s.match(/(?<prefix>.*)(?<suffix>\[.*-*\])/)
      if isrange != nil
        first = isrange['suffix'].match(/(?<num>[[:digit:]]*)-/)
        last  = isrange['suffix'].match(/-(?<num>[[:digit:]]*)/)
        range = Range.new(first['num'],last['num']).to_a
        range.sort.each do | nodenumber |
          hosts.push(isrange['prefix']+nodenumber)
        end
      else
        hosts.push(element)
      end
    end
  end
  whohastherole[key] = hosts
  hosts.each do | nodename|
    if hname == nodename
    then
      myroles.push(key) unless myroles.include?(key)
    end
  end
end



Facter.add(:myroles) do
  setcode do
    myroles
  end
end

Facter.add(:whohastherole) do
  setcode do
    whohastherole
  end
end
