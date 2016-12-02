class OutdatedMachinePresenter < Keynote::Presenter
presents :machine

  def name_link
    link_to(machine.name, machine)
  end

end
