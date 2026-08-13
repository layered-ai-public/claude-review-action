import { fetchSession } from '../../lib/api';

export default async function DashboardPage() {
  const session = await fetchSession();

  return (
    <main>
      <h1>Welcome back, {session.user.display_name}</h1>
      <p>{session.user.email}</p>
      <p>Last seen {session.user.last_seen_at}</p>
    </main>
  );
}
