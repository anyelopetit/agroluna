# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # InseminationsController
    class InseminationsController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_insemination, only: %i[show edit update destroy]
      before_action :index_variables
      before_action :form_variables, only: %i[new edit]
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@inseminations)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @insemination = Insemination.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @insemination = Insemination.new(insemination_params)

        if @insemination.save
          redirect(@insemination, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @insemination.update(insemination_params)
          redirect(@insemination, params)
        else
          render :edit
        end
      end

      def clone
        @insemination = Insemination.clone_record params[:insemination_id]
        @insemination.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @insemination.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Insemination.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Insemination.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Insemination.sorter(params[:row])
      end

      private

      def index_variables
        @q = Insemination.ransack(params[:q])
        @inseminations = @q.result(distinct: true)
        @objects = @inseminations.page(@current_page).order(position: :desc)
        @total = @inseminations.size
        @attributes = Insemination.index_attributes
      end

      def form_variables
        @species = KepplerCattle::Species.all
        @races = KepplerCattle::Race.all
        @farms = KepplerFarm::Farm.all
        @corporal_conditions = KepplerCattle::Status.corporal_conditions
        @colors = KepplerCattle::Cow.colors
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_insemination
        @insemination = Insemination.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def insemination_params
        params.require(:insemination).permit(
          :serie_number, :species_id, :race_id, :farm_id, :corporal_condition, :birthdate, :coat_color, :nose_color, :tassel_color, :provenance, :observations
        )
      end
    end
  end
end