# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # CorporalConditionsController
    class CorporalConditionsController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_corporal_condition, only: %i[show edit update destroy]
      before_action :set_species
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@corporal_conditions)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @corporal_condition = CorporalCondition.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @corporal_condition = CorporalCondition.new(corporal_condition_params)

        if @corporal_condition.save
          redirect(@corporal_condition, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @corporal_condition.update(corporal_condition_params)
          redirect(@corporal_condition, params)
        else
          render :edit
        end
      end

      def clone
        @corporal_condition = CorporalCondition.clone_record params[:corporal_condition_id]
        @corporal_condition.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @corporal_condition.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        CorporalCondition.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        CorporalCondition.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        CorporalCondition.sorter(params[:row])
      end

      private

      def set_species
        @species = Species.find(params[:species_id])
      end

      def index_variables
        @q = @species.corporal_conditions.ransack(params[:q])
        @corporal_conditions = @q.result(distinct: true)
        @objects = @corporal_conditions.page(@current_page).order(position: :desc)
        @total = @corporal_conditions.size
        @attributes = CorporalCondition.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_corporal_condition
        @corporal_condition = CorporalCondition.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def corporal_condition_params
        params.require(:corporal_condition).permit(
          CorporalCondition.attribute_names.map(&:to_sym)
        )
      end
    end
  end
end