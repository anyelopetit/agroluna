# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # CowsController
    class CowsController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_cow, only: %i[show edit update destroy]
      before_action :cow_attributes, only: %i[new edit]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@cows)
        redirect_to_index(@objects)
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

        if @cow.save && @cow.statuses.blank?
          # redirect(@cow, params)
          redirect_to new_admin_cattle_cow_status_path(@cow)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @cow.update(cow_params)
          if @cow.statuses.blank?
            redirect_to new_admin_cattle_cow_status_path(@cow)
          else 
            redirect(@cow, params)
          end
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
        @objects = @cows.page(@current_page).order(:serie_number)
        @total = @cows.size
        @attributes = Cow.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_cow
        @cow = Cow.find_by(id: params[:id])
      end

      def cow_attributes
        @species = Cow.species
        @genders = Cow.genders
        @races   = Cow.races
        @posible_mothers = Cow.posible_mothers
        @posible_fathers = Cow.posible_fathers
        @colors = Cow.colors
      end

      # Only allow a trusted parameter "white list" through.
      def cow_params
        params.require(:cow).permit(
          :image,
          :serie_number,
          :short_name,
          :long_name,
          :species_id,
          :race_id,
          :gender,
          :birthdate,
          :coat_color,
          :nose_color,
          :tassel_color,
          :provenance, 
          :observations,
          :mother_id,
          :father_id
        )
      end
    end
  end
end