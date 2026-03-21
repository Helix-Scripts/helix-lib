import { ThemeProvider } from './theme/ThemeProvider';

function App() {
  return (
    <ThemeProvider>
      <div id="helix-app">{/* Application content renders here */}</div>
    </ThemeProvider>
  );
}

export default App;
