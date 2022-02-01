class MaintenanceTemplatesController < ApplicationController
    def index
        @maintenance_templates = MaintenanceTemplate.all
    end

    def show
        @maintenance_template = MaintenanceTemplate.find(params[:id])
    end

    def new
        @maintenance_template = MaintenanceTemplate.new
    end

    def create
        @maintenance_template = MaintenanceTemplate.new(maintenance_template_params)
        if @maintenance_template.save
            return redirect_to maintenance_template_path(@maintenance_template)
        end

        return render :new
    end

    def edit
        @maintenance_template = MaintenanceTemplate.find(params[:id])
    end

    def update
        @maintenance_template = MaintenanceTemplate.find(params[:id])
        if @maintenance_template.update(maintenance_template_params)
            return redirect_to maintenance_template_path(@maintenance_template), notice: "Template updated!"
        end
        return render :edit
    end

    def destroy
        @maintenance_template = MaintenanceTemplate.find(params[:id])
        @maintenance_template.destroy
        redirect_to maintenance_templates_path, notice: "Template #{@maintenance_template.name} deleted"
    end

    private

    def maintenance_template_params
        params.require(:maintenance_template).permit(:name, :subject, :body, :invitation_contact)
      end
end
