[@react.component]
let make = (~name: string) => <button> {React.string("Hello " ++ name ++ "!")} </button>;