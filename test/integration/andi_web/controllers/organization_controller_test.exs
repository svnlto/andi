defmodule Andi.CreateOrgTest do
  use ExUnit.Case
  use Divo
  use Placebo
  use Tesla

  alias SmartCity.Organization
  alias SmartCity.TestDataGenerator, as: TDG

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000"

  @ou Application.get_env(:andi, :ldap_env_ou)

  setup_all do
    user = Application.get_env(:andi, :ldap_user)
    pass = Application.get_env(:andi, :ldap_pass)
    Paddle.authenticate(user, pass)

    Paddle.add([ou: @ou], objectClass: ["top", "organizationalunit"], ou: @ou)

    org = organization()
    {:ok, response} = create(org)
    [happy_path: org, response: response]
  end

  describe "successful organization creation" do
    test "responds with a 201", %{response: response} do
      assert response.status == 201
    end

    test "writes organization to LDAP", %{happy_path: expected} do
      expected_dn = "cn=#{expected.orgName},ou=#{@ou}"
      [actual] = Paddle.get!(filter: [cn: expected.orgName])
      assert actual["dn"] == expected_dn
    end

    test "writes to LDAP as group", %{happy_path: expected} do
      [actual] = Paddle.get!(filter: [cn: expected.orgName])
      assert actual["objectClass"] == ["top", "groupOfNames"]
    end

    test "writes to LDAP with an admin member", %{happy_path: expected} do
      [actual] = Paddle.get!(filter: [cn: expected.orgName])
      assert actual["member"] == ["cn=admin"]
    end

    test "persists organization for downstream use", %{happy_path: expected, response: resp} do
      id = Jason.decode!(resp.body)["id"]
      assert {:ok, actual} = Organization.get(id)
      assert actual.orgName == expected.orgName
    end

    test "persists organization with distinguished name", %{happy_path: expected, response: resp} do
      base = Application.get_env(:paddle, Paddle)[:base]
      id = Jason.decode!(resp.body)["id"]
      assert {:ok, actual} = Organization.get(id)
      assert actual.dn == "cn=#{expected.orgName},ou=#{@ou},#{base}"
    end
  end

  describe "failure to persist new organization" do
    setup do
      allow(Organization.write(any()), return: {:error, :reason}, meck_options: [:passthrough])
      org = organization(%{orgName: "unhappyPath"})
      {:ok, response} = create(org)
      [unhappy_path: org, response: response]
    end

    test "responds with a 500", %{response: response} do
      assert response.status == 500
    end

    test "removes organization from LDAP", %{unhappy_path: expected} do
      assert {:error, :noSuchObject} = Paddle.get(filter: [cn: expected.orgName, ou: @ou])
    end
  end

  describe "organization retrieval" do
    setup do
      expected = TDG.create_organization(%{})
      create(expected)
      {:ok, expected: expected}
    end

    test "returns all organzations", %{expected: expected} do
      result = get("/api/v1/organizations")

      organizations =
        elem(result, 1).body
        |> Jason.decode!()
        |> Enum.map(fn x ->
          {:ok, organization} = Organization.new(x)
          organization
        end)

      assert Enum.find(organizations, fn organization -> expected.id == organization.id end)
    end
  end

  defp create(org) do
    struct = Jason.encode!(org)

    post("/api/v1/organization", struct, headers: [{"content-type", "application/json"}])
  end

  defp organization(overrides \\ %{}) do
    overrides
    |> TDG.create_organization()
    |> Map.from_struct()
    |> Map.delete(:id)
  end
end
