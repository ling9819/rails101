class GroupsController < ApplicationController
	#這是 devise 內建的功能，只要把它放進 controller 裡面，就會自動驗證使用者是否入
	#不是所有 action 都一定要登入才行，只有跟 新增 / 修改 / 刪除 有關的 action 才需要先登入
	before_action :authenticate_user!,only: [:new, :edit, :create, :update, :destroy]

	def index
		@group = Group.all
	end
		#flash[:warning] = "這是warning訊息"
		def new
			@group = Group.new
		end

	def show
		@group = Group.find(params[:id])
		@posts = @group.posts
	end

	def edit
		#@group = Group.find(params[:id])
		@group =current_user.groups.find(params[:id])
	end

	def create
		#@group = Group.create(group_params)
		@group = current_user.groups.new(group_params)
		if @group.save
			current_user.join!(@group)
			redirect_to groups_path
		else
			render :new
		end
	end

	def update
		#@group = Group.find(params[:id])
		@group =current_user.groups.find(params[:id])

		if @group.update(group_params)
			redirect_to groups_path, notice:"修改討論版成功"
		else
			render :edit
		end
	end

	def destroy
			#@group = Group.find(params[:id])
			@group = current_user.groups.find(params[:id])
			@group.destroy
			redirect_to groups_path, alert: "討論版已刪除"
	end
	def join
		@group = Group.find(params[:id])

		if !current_user.is_member_of?(@group)
			current_user.join!(@group)
			flash[:notice] = "加入本討論板成功！"
		else
			flash[:warning] = "你已經是本討論板成員了！"
		end

		redirect_to group_path(@group)
	end

	def quit
		@group = Group.find(params[:id])

		if current_user.is_member_of?(@group)
			current_user.quit!(@group)
			flash[:alert] = "已退出本討論板！"
		else
			flash[:warning] ="你不是本討論板成員，怎麼退出 ＸＤ"
		end

		redirect_to group_path(@group)
	end



	private

	def group_params
		params.require(:group).permit(:title, :description)
	end
end
