class TagsController < ApplicationController

  def index
    tags = Tag.all.map do |tag|
      [name: tag.name,
      description: tag.description,
      total_mentions: tag.total_mentions,
      todays_mentions: tag.todays_mentions]
    end

    respond_to do |format|
      format.json{render status:200, json: tags.as_json}
    end
  end

end
