module Mco
  module Virsh
    class Domain
      include Virtus.model

      # Interface
      # {:source_bridge=>"br0", :type=>"bridge", :model_type=>"virtio",
      #  :target_dev=>"vnet0", :alias_name=>"net0",
      #  :mac_address=>"52:54:00:3f:75:6d"}
      #
      # Disk
      #
      # {:target_dev=>"vda", :driver_type=>"raw", :driver_name=>"qemu",
      #  :source_dev=>"/dev/vg_vmhost11/otris-centos", :target_bus=>"virtio"}

      attribute :name, String
      attribute :vcpu, Integer
      attribute :memory, Integer
      attribute :interfaces, Array[Hash]
      attribute :disks, Array[Hash]

      def mac_addresses
        interfaces.map {|i|
          i[:mac_address] || i['mac_address']
        }.compact.reject {|mac|
          mac.blank?
        }.map {|mac|
          mac.downcase
        }
      end
    end
  end
end
