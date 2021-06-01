class PokedexController < ApplicationController
  DEFAULT_LIMIT = 100

  def index
    render_json(PokedexEntry.all)
  end

  def show
    begin
      entry = PokedexEntry.find(id)
      render_json(entry)
    rescue
      render_json({ error: "An error has occured, please check your parameters" }, :bad_request)
    end
  end

  def create
    entry = PokedexEntry.new(entry_params)
    if entry.save
      render_json(entry)
    else
      render_json({ error: "Entry could not be created", errors: entry.errors }, :bad_request)
    end
  end

  def update
    begin
      entry = PokedexEntry.find(id)

      if entry.update(entry_params)
        render_json(entry)
      else
        render_json({ error: "Entry could not be updated", errors: entry.errors }, :bad_request)
      end
    rescue
      render_json({ error: "An error has occured, please check your parameters" }, :bad_request)
    end
  end

  def destroy
    begin
      entry = PokedexEntry.find(id)

      if entry.destroy
        render_json(entry)
      else
        render_json({ error: "Entry could not be deleted", errors: entry.errors }, :bad_request)
      end
    rescue
      render_json({ error: "An error has occured, please check your parameters" }, :bad_request)
    end
  end

  def pagination
    begin
      entries = PokedexEntry.all
      result = {
        entries: entries.limit(limit).offset(offset),
        meta: {
          count: entries.count,
          offset: offset,
          limit: limit
        }
      }
      render_json(result)
    rescue
      render_json({ error: "An error has occured, please check your parameters" }, :bad_request)
    end
  end

  private
    def entry_params
      params.permit([:no, :name, :type1, :type2, :hp, :attack, :defense, :spAtk, :spDef, :speed, :generation, :legendary])
    end

    def render_json(object, status = :ok)
      render json: object, status: status
    end

    def id
      if params[:id]
        res = Integer(params[:id])
        raise "Id must be greater or equal to one" if res < 1
        res
      else
        raise "Id is required"
      end
    end

    def limit
      if params[:limit]
        res = Integer(params[:limit])
        raise "Limit must be greater or equal to one" if res < 1
        res
      else
        DEFAULT_LIMIT
      end
    end

    def offset
      if params[:offset]
        res = Integer(params[:offset])
        raise "Offset must be greater or equal to zero" if res < 0
        res
      else
        0
      end
    end
end
