# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # TypologiesController
    class TypologiesController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_typology, only: %i[show edit update destroy]
      before_action :set_species
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@typologies)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @typology = Typology.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @typology = Typology.new(typology_params)

        if @typology.save
          redirect(@typology, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @typology.update(typology_params)
          redirect(@typology, params)
        else
          render :edit
        end
      end

      def clone
        @typology = Typology.clone_record params[:typology_id]
        @typology.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @typology.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Typology.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Typology.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Typology.sorter(params[:row])
      end

      private

      def set_species
        @species = Species.find(params[:species_id])
      end

      def index_variables
        @q = @species.typologies.ransack(params[:q])
        @typologies = @q.result(distinct: true)
        @objects = @typologies.page(@current_page).order(position: :desc).where(species_id: params[:species_id])
        @total = @typologies.size
        @attributes = Typology.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_typology
        @typology = Typology.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def typology_params
        params.require(:typology).permit(
          :name,
          :abbreviation,
          :gender,
          :counter,
          :min_age,
          :min_weight,
          :description,
          :species_id
        )
      end
    end
  end
end