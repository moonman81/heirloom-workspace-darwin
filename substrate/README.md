# substrate/ — Σ_heirloom N3 ontology of the port universe

Notation3 substrate modelling the 11-repo `moonman81/heirloom-*-darwin`
universe. Follows the discipline of the reduxed-sunsite substrate at
`/Volumes/mirrors-reduxed/sunsite.icm.edu.pl/{00,01,02,03,04,05,06}-*.n3`
that inspired this work.

## Files

```
00-ontology.n3     Σ_heirloom CLASS hierarchy (Repo, CodeRepo,
                   ReferenceRepo, ScaffoldRepo, WorkspaceRepo,
                   UpstreamProject, AncestorProject, CitationSource,
                   Binary, PersonalityVariant, ...).

01-signatures.n3   Σ_heirloom PREDICATE catalogue (portOf, derivedFrom,
                   citesBibliography, hostsCitations, companionOf,
                   supportsVariant, installedBinaryCount, ...).

02-models.n3       NAMED INSTANCES of every repo in the universe with
                   their metadata (size, purpose, licence posture,
                   redistribution flag, variant support, citations),
                   plus 5 example citation links code-repo → primary
                   source → reference-repo.

queries.sparql     8 example SPARQL queries.
```

## Validating

```sh
# rapper (raptor) — most permissive N3 parser
rapper -i turtle 00-ontology.n3 -c
rapper -i turtle 01-signatures.n3 -c
rapper -i turtle 02-models.n3 -c

# riot (Jena)
riot --count --syntax=Turtle 00-ontology.n3
riot --count --syntax=Turtle 01-signatures.n3
riot --count --syntax=Turtle 02-models.n3

# cwm (Notation3 reference implementation)
cwm 00-ontology.n3 01-signatures.n3 02-models.n3 --think
```

## Running queries

```sh
arq --data=00-ontology.n3 --data=01-signatures.n3 --data=02-models.n3 \
    --query=queries.sparql
```

Or, if you want to query a single question:

```sh
arq --data=02-models.n3 --query=- <<'SPARQL'
PREFIX h: <https://moonman81.github.io/heirloom/ontology#>
SELECT ?repo ?label ?size
WHERE {
    ?repo a h:ReferenceRepo ;
          rdfs:label ?label ;
          h:repoSize ?size .
} ORDER BY ?label
SPARQL
```

## What this enables

- Machine-readable provenance: given any Heirloom Darwin repo, you can
  query which upstream project it ports, which primary sources it
  cites, and which reference repo hosts those citations.
- Companion-relationship traversal: for any reference repo, find its
  companions.
- Variant coverage query: which code repos support which SVR4
  personalities.
- Non-authoritativeness invariant: Q8 in queries.sparql should return
  ZERO rows always — every repo carries `h:isAuthoritative false`.

## Discipline

Add a new instance whenever:
- A new sibling repo is created (add to `02-models.n3`).
- A code repo cites a new primary source (add citation triple to
  `02-models.n3` linking to its reference-repo host).
- A new personality variant is introduced (add to `00-ontology.n3`
  + `02-models.n3`).

Never claim `h:isAuthoritative true` for any Heirloom-Darwin repo.
The whole port disclaims that.

## Regenerating TREE.md from this substrate

`../TREE.md` at the workspace root is human-editable and manually
kept in sync with `02-models.n3`. A future improvement would be a
`render.sh` that runs the SPARQL queries and generates TREE.md
automatically — mirroring the reduxed-sunsite substrate's own
`render.sh` discipline. Not yet done; captured as future work.
