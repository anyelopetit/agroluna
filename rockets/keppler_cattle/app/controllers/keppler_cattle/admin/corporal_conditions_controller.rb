# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # CorporalConditionsController
    class CorporalConditionsController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_weighing_day, only: %i[show edit update destroy]
      before_action :set_species
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@weighing_days)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @weighing_day = CorporalCondition.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @weighing_day = CorporalCondition.new(weighing_day_params)

        if @weighing_day.save
          redirect(@weighing_day, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @weighing_day.update(weighing_day_params)
          redirect(@weighing_day, params)
        else
          render :edit
        end
      end

      def clone
        @weighing_day = CorporalCondition.clone_record params[:weighing_day_id]
        @weighing_day.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @weighing_day.destroy
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
        @q = CorporalCondition.ransack(params[:q])
        @weighing_days = @q.result(distinct: true)
        @objects = @weighing_days.page(@current_page).order(position: :desc)
        @total = @weighing_days.size
        @attributes = CorporalCondition.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_weighing_day
        @weighing_day = CorporalCondition.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def weighing_day_params
        params.require(:weighing_day).permit(
          :name, :min_days, :specific_day, :max_days, :species_id
        )
      end
    end
  end
end