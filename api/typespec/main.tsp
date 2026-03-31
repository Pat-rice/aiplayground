import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";
import "@typespec/versioning";

import "./models.tsp";
import "./routes.tsp";

using Http;
using OpenAPI;
using Versioning;

@service(#{ title: "Pet Store API" })
@server("http://localhost:8080", "Local development server")
@versioned(Versions)
@doc("A template Pet Store API built with TypeSpec, oapi-codegen, and sqlc.")
namespace PetStore;

enum Versions {
  v1: "1.0",
  v2: "2.0",
}
