# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # CowsController
    class CowsController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_cow, only: %i[show edit update destroy]
      before_action :cow_attributes, only: %i[new edit create]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@cows)
        redirect_to_index(@objects)
      end

      def filter_by_species
        puts "=========== #{params[:species_id]} ==================="
        return @cows = @objects if params[:species_id].eql?('all')
        @cows = @objects.where(species_id: params[:species_id]).page(@current_page).order(:serie_number)
        puts "=========== #{@cows.size} ==================="
      end

      # GET /cattles/1
      def show
        @statuses = @cow.statuses.order(created_at: :desc)
      end

      # GET /cattles/new
      def new
        @cow = Cow.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @cow = Cow.new(cow_params)
        
        unless params[:cow][:father_id].blank?
          @cow.father_type = params[:cow][:father_id].split(',').first
          @cow.father_id = params[:cow][:father_id].split(',').last.to_i
        end

        if @cow.save! && @cow.weights.blank?
          @cow.mother.create_typology unless @cow.mother.blank?
          redirect_to new_admin_cattle_cow_weight_path(@cow&.id)
        else
          flash[:error] = 'Revisa los datos del formulario'
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @cow.update(cow_params)
          redirect(@cow, params)
        else
          render :edit
        end
      end

      def clone
        @cow = Cow.clone_record params[:cow_id]
        @cow.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @cow.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Cow.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Cow.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Cow.sorter(params[:row])
      end

      private

      def index_variables
        @q = Cow.ransack(params[:q])
        @cows = @q.result(distinct: true)
        @objects = @cows.includes(:race).page(@current_page).order(:serie_number)
        @total = @cows.size
        @attributes = Cow.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_cow
        @cow = Cow.find_by(id: params[:id])
      end

      def cow_attributes
        @species = KepplerCattle::Species.all
        @genders = KepplerCattle::Cow.genders
        @races   = @species.first.races
        @possible_mothers = KepplerCattle::Cow.possible_mothers_select2
        @possible_fathers = KepplerCattle::Cow.possible_fathers_select2
        @colors = KepplerCattle::Cow.colors
      end

      # Only allow a trusted parameter "white list" through.
      def cow_params
        params.require(:cow).permit(
          KepplerCattle::Cow.attribute_names.map(&:to_sym)
        )
      end
    end
  end
end