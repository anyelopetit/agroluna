# frozen_string_literal: true

require_dependency "keppler_farm/application_controller"
module KepplerFarm
  module Admin
    # ProcessesController
    class ProcessesController < ::Admin::AdminController
      layout 'keppler_farm/admin/layouts/application'
      before_action :set_process, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /farms
      def index
        respond_to_formats(@processes)
        redirect_to_index(@objects)
      end

      # GET /farms/1
      def show; end

      # GET /farms/new
      def new
        @process = Process.new
      end

      # GET /farms/1/edit
      def edit; end

      # POST /farms
      def create
        @process = Process.new(process_params)

        if @process.save
          redirect(@process, params)
        else
          render :new
        end
      end

      # PATCH/PUT /farms/1
      def update
        if @process.update(process_params)
          redirect(@process, params)
        else
          render :edit
        end
      end

      def clone
        @process = Process.clone_record params[:process_id]
        @process.save
        redirect_to_index(@objects)
      end

      # DELETE /farms/1
      def destroy
        @process.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Process.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Process.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Process.sorter(params[:row])
      end

      private

      def index_variables
        @q = Process.ransack(params[:q])
        @processes = @q.result(distinct: true)
        @objects = @processes.page(@current_page).order(position: :desc)
        @total = @processes.size
        @attributes = Process.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_process
        @process = Process.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def process_params
        params.require(:process).permit(
          :title
        )
      end
    end
  end
end