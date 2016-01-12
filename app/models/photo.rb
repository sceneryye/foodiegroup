class Photo < ActiveRecord::Base
  belongs_to :groupbuy
  belongs_to :event
  mount_uploader :image, PictureUploader
  include Rails.application.routes.url_helpers

  def to_jq_upload
        {
          "name"        => read_attribute(:name),
          "size"        => read_attribute(:size),
          "url"         => self.image_url(),
          "small_url"   => self.image_url(:small),
          "delete_url"  => photo_path(self),
          "delete_type" => "DELETE"
        }
    end

    before_save :update_banner_attributes

    private

    def update_banner_attributes
        if file.present? && file_changed?
            self.name         = file.file.filename
            self.size         = file.file.size
            self.content_type = file.file.content_type
        end
    end
end
