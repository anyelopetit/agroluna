# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # WeightsController
    class WeightsController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_cow
      before_action :set_weight, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@weights)
        redirect_to admin_cattle_cow_path(@cow)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @weight = Weight.new
        @corporal_conditions = @cow.species.corporal_conditions
      end

      # GET /cattles/1/edit
      def edit
        @corporal_conditions = @cow.species.corporal_conditions
      end

      # POST /cattles
      def create
        @weight = Weight.new(weight_params)

        if @weight.save
          redirect_to admin_cattle_cow_path(@cow)
        else
          render :new
          @corporal_conditions = @cow.species.corporal_conditions
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @weight.update(weight_params)
          redirect_to admin_cattle_cow_path(@cow)
        else
          render :edit
        end
      end

      def clone
        @weight = Weight.clone_record params[:weight_id]
        @weight.save
        redirect_to admin_cattle_cow_path(@cow)
      end

      # DELETE /cattles/1
      def destroy
        @weight.destroy
        redirect_to admin_cattle_cow_path(@cow)
      end

      def destroy_multiple
        Weight.destroy redefine_ids(params[:multiple_ids])
        redirect_to admin_cattle_cow_path(@cow)
      end

      def upload
        Weight.upload(params[:file])
        redirect_to admin_cattle_cow_path(@cow)
      end

      def reload; end

      def sort
        Weight.sorter(params[:row])
      end

      private

      def set_cow
        @cow = Cow.find_by(id: params[:cow_id])
      end

      def index_variables
        @q = Weight.ransack(params[:q])
        @weights = @q.result(distinct: true)
        @objects = @weights.page(@current_page).order(position: :desc)
        @total = @weights.size
        @attributes = Weight.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_weight
        @weight = Weight.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def weight_params
        params.require(:weight).permit(
          Weight.attribute_names.map(&:to_sym)
        )
      end
    end
  end
end