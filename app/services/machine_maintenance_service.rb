class MachineMaintenanceService
  def process_message(message)
    user = UserService.update_from_virtual_user(message.user)
    machine = Machine.find_by(fqdn: message.fqdn)

    unless machine
      # try to find the machine also by alias
      aliass = MachineAlias.find_by(name: message.fqdn)
      machine = aliass.machine if aliass
    end

    record = nil

    Machine.transaction do
      # Set the service date directly on the machine.
      # This might become obsolete in the future.
      unless message.noservice == "true"
        machine.update(serviced_at: message.timestamp) if machine
      end

      record = MaintenanceRecord.create!({
        fqdn: message.fqdn,
        user: user,
        machine: machine,
        logfile: message.screenlog,
        created_at: message.timestamp
      })
    end

    if !machine && record
      AlertMailer.dangling_maintenance_record(record, user).deliver
    end
  end

  def process_from_controller(controller, params)
    record = MaintenanceRecord.new(params)
    record.user = controller.current_user

    Machine.transaction do
      if record.save
        add_attachments(params[:attachments])
        record.machine.update(serviced_at: Time.now)
        controller.redirect_to controller.machine_path(record.machine)
      else
        controller.render :new, status: :unprocessable_entity
      end
    end
  end

  def add_attachments(attachments)
    if attachments
      attachments.each { |attachment|
        @record.attachments.create(attachment: attachment)
      }
    end
  end
end
