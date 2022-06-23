module SoftwareHelper
  def self.software_machines(all_machines, package, version = "")
    machines = Array.new

    if !package.blank?
      query = ":name=>\""+package+"\""
      if !version.blank?
        query = ":name=>\""+package+"\", :version=>\""+version
      end
      machines = all_machines.includes(:owner, nics: [:ip_address]).order(:fqdn).where("software LIKE ?", "%"+query+"%")
    end

    machines.uniq
  end

  def self.software_to_a(machine)
    array = Array.new
    return nil unless machine.software

    first_pass = machine.software.tr("\"", "").tr("[", "").tr("]", "")[1...-1].split("}, {")
    first_pass.each do |e| 
      e.gsub!(":name", "")
      e.gsub!(":version", "")
      e.gsub!("=>", "")
      array << e.split(", ")
    end
    array
  end
end
