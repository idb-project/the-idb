class VersionChangeWorker
  include Sidekiq::Worker

  def perform(version_id, username)
    version = PaperTrail::Version.find_by_id(version_id)

    if version
      if version.item
        logger.info { "Process version change for #{version.item.class}##{version.item.id}" }

        ObjectChangeMailer.diff_email(version, username).deliver
      else
        # the item this version is assigned to does no longer exists, so delete the version as well
        version.delete
      end
    end
  end
end
