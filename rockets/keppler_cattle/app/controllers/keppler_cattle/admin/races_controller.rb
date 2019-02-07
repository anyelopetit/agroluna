# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # RacesController
    class RacesController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_race, only: %i[show edit update destroy]
      before_action :set_species
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@races)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @race = Race.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @race = Race.new(race_params)

        if @race.save
          redirect(@race, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @race.update(race_params)
          redirect(@race, params)
        else
          render :edit
        end
      end

      def clone
        @race = Race.clone_record params[:race_id]
        @race.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @race.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Race.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Race.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Race.sorter(params[:row])
      end

      private

      def set_species
        @species = Species.find(params[:species_id])
      end

      def index_variables
        @q = Race.ransack(params[:q])
        @races = @q.result(distinct: true)
        @objects = @races.page(@current_page).order(position: :desc)
        @total = @races.size
        @attributes = Race.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_race
        @race = Race.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def race_params
        params.require(:race).permit(
          :name, :abbreviation, :description
        )
      end
    end
  end
end