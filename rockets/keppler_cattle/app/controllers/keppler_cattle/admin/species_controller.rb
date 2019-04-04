# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # SpeciesController
    class SpeciesController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_species, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@species)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show
        redirect_to_index(@objects)
      end

      # GET /cattles/new
      def new
        @species = Species.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @species = Species.new(species_params)

        if @species.save
          redirect_to_index(@objects)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @species.update(species_params)
          redirect_to_index(@objects)
        else
          render :edit
        end
      end

      def clone
        @species = Species.clone_record params[:species_id]
        @species.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @species.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Species.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Species.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Species.sorter(params[:row])
      end

      def get_races
        @races = Species.find(params[:species_id]).races
        respond_to do |format|
          format.js
        end
      end

      private

      def index_variables
        @q = Species.ransack(params[:q])
        @species = @q.result(distinct: true)
        @objects = @species.page(@current_page).order(position: :desc)
        @total = @species.size
        @attributes = Species.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_species
        @species = Species.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def species_params
        params.require(:species).permit(
          :name, :abbreviation
        )
      end
    end
  end
end