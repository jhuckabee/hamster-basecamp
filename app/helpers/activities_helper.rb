module ActivitiesHelper
  def grouped_todo_items(todos)
   todos.collect{|t| [t.name, t.todo_items.collect{|i| [i.content, i.id]}] }
  end

  def grouped_todo_item_options(todos)
   grouped_options_for_select(grouped_todo_items(todos))
  end
end
