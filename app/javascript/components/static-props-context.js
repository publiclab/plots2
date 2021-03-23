import React from "react";

// creates universal access to static props (translation strings, node author & id) (so we don't have to pass them through components)

export const StaticPropsContext = React.createContext(
  {} // default value
);
