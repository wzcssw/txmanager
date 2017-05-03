class Admin::V1::DiagnoseCentersAPI < Grape::API
  resources :diagnose_centers do

    desc "阅片中心"
    get :get_page_data do
        @dc = DiagnoseCenter.page(params[:page]).per(params[:page_size])
        present :success, true
        present :row_arr, @dc,with: DiagnoseCenterEntity
        present :current_page, @dc.current_page
        present :all_page, @dc.total_pages
        present :row_count, @dc.total_count
        present :page_size,@dc.size
    end

    desc "保存阅片中心"
    params do
      requires :name, type: String
    end
    post :save do
      @dc = nil
      if params[:id].present?
        @dc = DiagnoseCenter.find(params[:id])
      else
        @dc = DiagnoseCenter.new
      end
      @dc.name = params[:name] if params[:name].present?
      @dc.description = params[:description]
      @dc.is_open = params[:is_open] if params[:is_open].present?
      @dc.rank = params[:rank] if params[:rank].present?
      @dc.save
      present :success, true
      present :data, @dc
    end

    desc "修改阅片中心状态"
    params do
      requires :id, type: String
      requires :is_open ,type: Boolean
    end
    post :change_state do
      DiagnoseCenter.find(params[:id]).update(is_open: params[:is_open])
      present :success, true
    end

    desc "阅片中心绑定医院"
    params do
      requires :id, type: String
    end
    post :binding_hospital do
      DiagnoseCenterHospital.where(diagnose_center_id: params[:id]).destroy_all
      params[:hospital_ids].each do |id|
        DiagnoseCenterHospital.where(diagnose_center_id: params[:id],hospital_id: id).first_or_create
      end
      present :success, true
    end

    desc "阅片中心用户"
    params do
      # requires :id, type: String
    end
    get :dc_users do
      @user = DcUser.page(params[:page]).per(params[:page_size])

      present :success, true
      present :row_arr, @user,with: DcUserEntity
      present :current_page, @user.current_page
      present :all_page, @user.total_pages
      present :row_count, @user.total_count
      present :page_size,@user.size
    end

    desc "保存阅片中心人员"
    params do
      # requires :name, type: String
    end
    post :save_manager do
      @user = nil
      if params[:id].present?
        @user = DcUser.find(params[:id])
      else
        @user = DcUser.new
      end
      @user.diagnose_center_id = params[:diagnose_center_id]
      @user.email = params[:email]
      @user.phone = params[:phone]
      @user.realname = params[:realname]
      @user.username = params[:username]
      @user.password = params[:password] if params[:password].present?
      @user.rank = params[:rank] if params[:rank].present?
      result = @user.save
      DcUserRole.where(dc_user_id: @user.id,dc_role_id: params[:dc_role_id]).first_or_create if result.present?
      present :success, result.present?
    end

  end
end
