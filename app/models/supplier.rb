class Supplier < ActiveRecord::Base
  #self.abstract_class = true
  establish_connection :tradev_mdk
  self.table_name = "sdb_imodec_suppliers"

end
