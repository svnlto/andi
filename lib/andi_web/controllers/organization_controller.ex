defmodule AndiWeb.OrganizationController do
  use AndiWeb, :controller

  require Logger
  alias SmartCity.Organization

  def create(conn, _params) do
    message = add_uuid(conn.body_params)
    pre_id = message["id"]

    with :ok <- ensure_new_org(pre_id),
         {:ok, organization} <- Organization.new(message),
         :ok <- write_to_redis(organization) do
      conn
      |> put_status(:created)
      |> json(organization)
    else
      error ->
        Logger.error("Failed to create organization: #{inspect(error)}")

        conn
        |> put_status(:internal_server_error)
        |> json("Unable to process your request: #{inspect(error)}")
    end
  end

  defp ensure_new_org(id) do
    case Organization.get(id) do
      {:ok, %Organization{}} ->
        Logger.error("ID #{id} already exists")
        %RuntimeError{message: "ID #{id} already exists"}

      {:error, %Organization.NotFound{}} ->
        :ok

      _ ->
        %RuntimeError{message: "Unknown error for #{id}"}
    end
  end

  defp add_uuid(message) do
    uuid = UUID.uuid4()

    Map.merge(message, %{"id" => uuid}, fn _k, v1, _v2 -> v1 end)
  end

  defp write_to_redis(org) do
    case Organization.write(org) do
      {:ok, _} ->
        :ok

      error ->
        error
    end
  end

  def get_all(conn, _params) do
    with {:ok, orgs} <- Organization.get_all() do
      conn
      |> put_status(:ok)
      |> json(orgs)
    else
      error ->
        Logger.error("Failed to retrieve organizations: #{inspect(error)}")

        conn
        |> put_status(:not_found)
        |> json("Unable to process your request")
    end
  end
end
