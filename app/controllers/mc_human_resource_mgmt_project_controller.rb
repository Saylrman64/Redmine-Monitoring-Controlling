class McHumanResourceMgmtProjectController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project, :authorize
  menu_item :redmine_monitoring_controlling
  
  def index    
    #tool instance
    tool = McTools.new
    
    #get main project
    @project = Project.find_by_identifier(params[:id])

    #get projects and sub projects
    stringSqlProjectsSubProjects = tool.return_ids(@project.id)    

    @statusesByAssigneds = Issue.find_by_sql("select assigned_to_id, (select firstname from users where id = assigned_to_id) as assigned_name,
                                              issue_statuses.id, issue_statuses.name, 
                                         	    (select COUNT(1) 
                                               from issues i 
                                               where i.project_id in (#{stringSqlProjectsSubProjects})
                                               and ((i.assigned_to_id = issues.assigned_to_id and i.assigned_to_id is not null)or(i.assigned_to_id is null and issues.assigned_to_id is null)) and i.status_id = issue_statuses.id) as totalassignedbystatuses
                                               from issues, issue_statuses  
                                               where project_id in (#{stringSqlProjectsSubProjects}) 
                                               group by assigned_to_id, assigned_name, issue_statuses.id, issue_statuses.name
                                               order by 2,3;")    
  end

  private
  def find_project
    @project=Project.find(params[:id])
  end


end