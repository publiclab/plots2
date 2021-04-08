import React from "react";

// creates a universal currentUser state accessible anywhere in the component tree
// see React Context: https://reactjs.org/docs/context.html

export const UserContext = React.createContext(
  null // default value
);
