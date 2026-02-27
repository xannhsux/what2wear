import Link from "next/link";

export default function Home() {
  return (
    <div className="flex min-h-[calc(100vh-8rem)] flex-col items-center justify-center px-6 pt-16">
      {/* Hero */}
      <section className="mx-auto max-w-3xl py-24 text-center md:py-32">
        <h1 className="animate-fade-in text-balance text-5xl font-bold tracking-tight md:text-7xl">
          Your AI-Powered
          <br />
          <span className="text-accent">Wardrobe</span>
        </h1>
        <p className="mx-auto mt-6 max-w-lg animate-slide-up text-lg text-gray-500">
          Train a personal AI model from your selfies, then generate yourself in
          any outfit, any style, any scene.
        </p>
        <div className="mt-10 animate-slide-up">
          <Link
            href="/avatar"
            className="inline-flex rounded-full bg-accent px-8 py-3.5 text-base font-medium text-white transition-all hover:bg-accent-hover hover:scale-[1.02] active:scale-[0.98]"
          >
            Create Your Avatar
          </Link>
        </div>
      </section>

      {/* Steps */}
      <section className="mx-auto w-full max-w-4xl pb-24">
        <div className="grid gap-8 md:grid-cols-3">
          {[
            {
              step: "01",
              title: "Upload Selfies",
              desc: "Upload 4–20 clear photos of yourself from different angles",
            },
            {
              step: "02",
              title: "AI Trains",
              desc: "Our AI learns your face, hairstyle, and unique features (~10 min)",
            },
            {
              step: "03",
              title: "Generate Outfits",
              desc: "Describe any outfit and see yourself wearing it instantly",
            },
          ].map((item) => (
            <div key={item.step} className="text-center">
              <span className="text-sm font-semibold text-accent">
                {item.step}
              </span>
              <h3 className="mt-2 text-lg font-semibold">{item.title}</h3>
              <p className="mt-1 text-sm text-gray-500">{item.desc}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
